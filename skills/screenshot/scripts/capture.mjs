#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import crypto from 'node:crypto';
import { spawn, spawnSync } from 'node:child_process';
import { pathToFileURL } from 'node:url';

const DEFAULT_TIMEOUT_MS = Number(process.env.SF_SCREENSHOT_TIMEOUT_MS || 30_000);
const DEFAULT_WAIT_MS = Number(process.env.SF_SCREENSHOT_WAIT_MS || 500);
const RUNTIME_DIR = process.env.SF_SCREENSHOT_RUNTIME_DIR ||
  path.join(os.homedir(), '.cache', 'software-factory', 'screenshot-runtime');

function usage() {
  console.log(`Usage:\n  capture.sh --project DIR --viewport WIDTHxHEIGHT [options]\n\nRequired:\n  --project DIR              Web project root.\n  --viewport WIDTHxHEIGHT    Example: 1440x900.\n\nOptions:\n  --url URL                  App origin, e.g. http://localhost:3000\n  --route PATH               Default: /\n  --output FILE              Screenshot PNG path.\n  --metadata-output FILE     Evidence JSON path.\n  --startup-script NAME      Existing package.json script.\n  --startup-command CMD      Existing startup command.\n  --timeout MS               Default: ${DEFAULT_TIMEOUT_MS}\n  --wait-ms MS               Default: ${DEFAULT_WAIT_MS}\n  --wait-for-selector CSS    Wait until selector is visible.\n  --state LABEL              Evidence state label.\n  --full-page                Capture full page.\n  --keep-app                 Keep an app started by this script running.\n  --no-start                 Never start the app.\n  --help                     Show help.\n\nExit codes:\n  0  PASS\n  1  FAILED\n  2  BLOCKED`);
}

function exitCode(status) {
  return status === 'PASS' ? 0 : status === 'BLOCKED' ? 2 : 1;
}

function result(status, reason, fields = {}) {
  const data = { status, reason, ...fields };
  const lines = [`Status: ${status}`, `Reason: ${reason}`];
  if (fields.url) lines.push(`URL: ${fields.url}`);
  if (fields.viewport) lines.push(`Viewport: ${fields.viewport}`);
  if (fields.route) lines.push(`Route: ${fields.route}`);
  if (fields.screenshot) lines.push(`Screenshot: ${fields.screenshot}`);
  if (fields.metadata) lines.push(`Metadata: ${fields.metadata}`);
  return { data, text: lines.join('\n') };
}

function parseArgs(argv) {
  const a = {
    project: null,
    url: null,
    viewport: null,
    route: '/',
    output: null,
    metadata: null,
    startupScript: null,
    startupCommand: null,
    timeout: DEFAULT_TIMEOUT_MS,
    waitMs: DEFAULT_WAIT_MS,
    selector: null,
    state: 'default',
    fullPage: false,
    keepApp: false,
    noStart: false,
  };

  const value = (argv, i, option) => {
    if (i + 1 >= argv.length) throw new Error(`${option} requires a value.`);
    return [argv[i + 1], i + 1];
  };

  for (let i = 0; i < argv.length; i += 1) {
    const option = argv[i];
    switch (option) {
      case '--help':
      case '-h':
        usage();
        return null;
      case '--project': {
        const [v, next] = value(argv, i, option); a.project = v; i = next; break;
      }
      case '--url': {
        const [v, next] = value(argv, i, option); a.url = v; i = next; break;
      }
      case '--viewport': {
        const [v, next] = value(argv, i, option); a.viewport = v; i = next; break;
      }
      case '--route': {
        const [v, next] = value(argv, i, option); a.route = v; i = next; break;
      }
      case '--output': {
        const [v, next] = value(argv, i, option); a.output = v; i = next; break;
      }
      case '--metadata-output': {
        const [v, next] = value(argv, i, option); a.metadata = v; i = next; break;
      }
      case '--startup-script': {
        const [v, next] = value(argv, i, option); a.startupScript = v; i = next; break;
      }
      case '--startup-command': {
        const [v, next] = value(argv, i, option); a.startupCommand = v; i = next; break;
      }
      case '--timeout': {
        const [v, next] = value(argv, i, option); a.timeout = Number(v); i = next; break;
      }
      case '--wait-ms': {
        const [v, next] = value(argv, i, option); a.waitMs = Number(v); i = next; break;
      }
      case '--wait-for-selector': {
        const [v, next] = value(argv, i, option); a.selector = v; i = next; break;
      }
      case '--state': {
        const [v, next] = value(argv, i, option); a.state = v; i = next; break;
      }
      case '--full-page': a.fullPage = true; break;
      case '--keep-app': a.keepApp = true; break;
      case '--no-start': a.noStart = true; break;
      default: throw new Error(`Unknown option: ${option}`);
    }
  }

  if (!a.project) throw new Error('--project is required.');
  a.project = path.resolve(a.project);
  if (!fs.existsSync(a.project) || !fs.statSync(a.project).isDirectory()) {
    throw new Error(`Invalid project directory: ${a.project}`);
  }

  const match = /^(\d{1,5})x(\d{1,5})$/i.exec(a.viewport || '');
  if (!match) throw new Error('--viewport must be WIDTHxHEIGHT.');
  a.width = Number(match[1]);
  a.height = Number(match[2]);

  if (!Number.isFinite(a.timeout) || a.timeout < 1000) throw new Error('--timeout must be at least 1000ms.');
  if (!Number.isFinite(a.waitMs) || a.waitMs < 0) throw new Error('--wait-ms cannot be negative.');
  if (a.noStart && !a.url) throw new Error('--url is required with --no-start.');
  return a;
}

function readPackage(project) {
  const file = path.join(project, 'package.json');
  if (!fs.existsSync(file)) throw new Error(`package.json not found in ${project}.`);
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch {
    throw new Error(`Unable to parse ${file}.`);
  }
}

function detectPackageManager(project, pkg) {
  const declared = typeof pkg.packageManager === 'string' ? pkg.packageManager.split('@')[0] : '';
  if (['npm', 'pnpm', 'yarn', 'bun'].includes(declared)) return declared;
  if (fs.existsSync(path.join(project, 'pnpm-lock.yaml'))) return 'pnpm';
  if (fs.existsSync(path.join(project, 'yarn.lock'))) return 'yarn';
  if (fs.existsSync(path.join(project, 'bun.lockb')) || fs.existsSync(path.join(project, 'bun.lock'))) return 'bun';
  return 'npm';
}

function discoverStartup(project, explicitScript, explicitCommand) {
  if (explicitCommand) return { command: explicitCommand, source: 'caller' };

  const pkg = readPackage(project);
  const scripts = pkg.scripts || {};
  const name = explicitScript || ['dev', 'start', 'preview'].find((key) => typeof scripts[key] === 'string');
  if (!name) throw new Error('No existing startup script found. Expected dev, start, or preview.');
  if (explicitScript && typeof scripts[explicitScript] !== 'string') {
    throw new Error(`package.json does not define startup script "${explicitScript}".`);
  }

  const manager = detectPackageManager(project, pkg);
  const commands = {
    npm: `npm run ${name}`,
    pnpm: `pnpm run ${name}`,
    yarn: `yarn ${name}`,
    bun: `bun run ${name}`,
  };
  return { command: commands[manager], source: `package.json script "${name}" via ${manager}` };
}

function spawnApp(project, command, logPath) {
  fs.mkdirSync(path.dirname(logPath), { recursive: true });
  const fd = fs.openSync(logPath, 'a');
  const env = { ...process.env, FORCE_COLOR: '0' };
  const child = process.platform === 'win32'
    ? spawn('cmd.exe', ['/d', '/s', '/c', command], {
        cwd: project,
        detached: true,
        windowsHide: true,
        stdio: ['ignore', fd, fd],
        env,
      })
    : spawn('bash', ['-lc', command], {
        cwd: project,
        detached: true,
        stdio: ['ignore', fd, fd],
        env,
      });
  fs.closeSync(fd);
  child.unref();
  return child;
}

function stopApp(child) {
  if (!child?.pid) return;
  try {
    if (process.platform === 'win32') {
      spawnSync('taskkill', ['/PID', String(child.pid), '/T', '/F'], {
        windowsHide: true,
        stdio: 'ignore',
      });
    } else {
      process.kill(-child.pid, 'SIGTERM');
    }
  } catch {}
}

function tail(file, maxChars = 16_000) {
  try {
    const text = fs.readFileSync(file, 'utf8');
    return text.slice(Math.max(0, text.length - maxChars));
  } catch {
    return '';
  }
}

function urlFromLog(text) {
  const matches = text.match(/https?:\/\/(?:localhost|127\.0\.0\.1|\[::1\])(?::\d+)?/g);
  return matches?.at(-1) || null;
}

async function reachable(url) {
  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 3000);
    const response = await fetch(url, { signal: controller.signal, redirect: 'manual' });
    clearTimeout(timer);
    return response.status < 500;
  } catch {
    return false;
  }
}

async function waitForApp(initialUrl, child, logPath, timeoutMs) {
  const deadline = Date.now() + timeoutMs;
  let url = initialUrl;

  while (Date.now() < deadline) {
    if (child?.exitCode !== null) {
      throw new Error(`Application exited during startup. Log: ${logPath}`);
    }
    if (!url) url = urlFromLog(tail(logPath));
    if (url && await reachable(url)) return url;
    await new Promise((resolve) => setTimeout(resolve, 250));
  }

  throw new Error(`Application did not become reachable within ${timeoutMs}ms. Log: ${logPath}`);
}

function defaultOutput(project) {
  const dir = path.join(project, '.factory', 'screenshots');
  fs.mkdirSync(dir, { recursive: true });
  return path.join(dir, `screenshot-${new Date().toISOString().replace(/[:.]/g, '-')}.png`);
}

async function loadPlaywright() {
  const file = path.join(RUNTIME_DIR, 'node_modules', 'playwright', 'index.js');
  if (!fs.existsSync(file)) throw new Error('Factory Playwright runtime is not installed.');
  return import(pathToFileURL(file).href);
}

async function main() {
  let args;
  try {
    args = parseArgs(process.argv.slice(2));
  } catch (error) {
    const r = result('BLOCKED', error.message);
    console.log(r.text);
    return 2;
  }

  if (!args) return 0;

  let playwright;
  try {
    playwright = await loadPlaywright();
  } catch (error) {
    const r = result('BLOCKED', error.message);
    console.log(r.text);
    return 2;
  }

  const logPath = path.join(
    RUNTIME_DIR,
    'logs',
    `${path.basename(args.project).replace(/[^A-Za-z0-9._-]+/g, '-')}-${process.pid}.log`,
  );

  let child = null;
  let startedBySkill = false;
  let browser = null;
  let context = null;
  let successful = false;
  let targetUrl = args.url;

  try {
    if (!targetUrl || !(await reachable(targetUrl))) {
      if (args.noStart) {
        const r = result('BLOCKED', 'Application is not reachable and --no-start was supplied.', {
          url: targetUrl || '', viewport: args.viewport, route: args.route,
        });
        console.log(r.text);
        return 2;
      }

      const startup = discoverStartup(args.project, args.startupScript, args.startupCommand);
      fs.mkdirSync(path.dirname(logPath), { recursive: true });
      fs.writeFileSync(
        logPath,
        `Factory screenshot startup\nTime: ${new Date().toISOString()}\nProject: ${args.project}\nCommand: ${startup.command}\nSource: ${startup.source}\n\n`,
      );

      child = spawnApp(args.project, startup.command, logPath);
      startedBySkill = true;
      targetUrl = await waitForApp(targetUrl, child, logPath, args.timeout);
    }

    const finalUrl = new URL(args.route, targetUrl).toString();
    const screenshotPath = path.resolve(args.output || defaultOutput(args.project));
    const metadataPath = path.resolve(args.metadata || screenshotPath.replace(/\.png$/i, '.json'));
    fs.mkdirSync(path.dirname(screenshotPath), { recursive: true });
    fs.mkdirSync(path.dirname(metadataPath), { recursive: true });

    browser = await playwright.chromium.launch({ headless: true });
    context = await browser.newContext({
      viewport: { width: args.width, height: args.height },
      deviceScaleFactor: 1,
    });

    const page = await context.newPage();
    const response = await page.goto(finalUrl, {
      waitUntil: 'domcontentloaded',
      timeout: args.timeout,
    });

    if (args.selector) {
      await page.locator(args.selector).first().waitFor({ state: 'visible', timeout: args.timeout });
    }

    await page.evaluate(async () => {
      if (document.fonts?.ready) {
        try { await document.fonts.ready; } catch {}
      }
    });

    if (args.waitMs > 0) await page.waitForTimeout(args.waitMs);

    await page.screenshot({
      path: screenshotPath,
      fullPage: args.fullPage,
      animations: 'disabled',
      caret: 'hide',
    });

    const sha256 = crypto.createHash('sha256').update(fs.readFileSync(screenshotPath)).digest('hex');
    const evidence = {
      status: 'PASS',
      capturedAt: new Date().toISOString(),
      project: args.project,
      url: page.url(),
      viewport: args.viewport,
      route: args.route,
      state: args.state,
      httpStatus: response?.status() ?? null,
      screenshot: screenshotPath,
      sha256,
      startedBySkill,
      appPid: startedBySkill ? child?.pid ?? null : null,
      startupCommand: startedBySkill ? discoverStartup(args.project, args.startupScript, args.startupCommand).command : null,
      startupLog: startedBySkill ? logPath : null,
      cleanup: startedBySkill && !args.keepApp ? 'stopped-started-process' : startedBySkill ? 'kept-running' : 'not-applicable',
    };

    fs.writeFileSync(metadataPath, `${JSON.stringify(evidence, null, 2)}\n`);
    console.log([
      'Screenshot',
      '',
      'Status: PASS',
      `URL: ${page.url()}`,
      `Viewport: ${args.viewport}`,
      `Route: ${args.route}`,
      `State: ${args.state}`,
      `Screenshot: ${screenshotPath}`,
      `Metadata: ${metadataPath}`,
      `SHA256: ${sha256}`,
    ].join('\n'));

    successful = true;
    return 0;
  } catch (error) {
    const r = result('FAILED', error?.message || String(error), {
      url: targetUrl || undefined,
      viewport: args.viewport,
      route: args.route,
    });
    console.log(r.text);
    return 1;
  } finally {
    try { await context?.close(); } catch {}
    try { await browser?.close(); } catch {}
    if (startedBySkill && !args.keepApp) stopApp(child);
    if (!successful && startedBySkill) {
      console.error(`Startup log: ${logPath}`);
    }
  }
}

process.exitCode = await main();
