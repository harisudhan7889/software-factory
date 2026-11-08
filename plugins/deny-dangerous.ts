import type { Plugin } from "@opencode-ai/plugin";
import { spawnSync } from "node:child_process";
import { realpathSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

// Factory-owned guard. DENY_DANGEROUS_GUARD overrides the path for
// testing/alternate deploys only. Otherwise the guard is found relative to
// this plugin file (resolving symlinks), so the plugin works from any install
// location: <factory>/plugins/deny-dangerous.ts -> <factory>/hooks/deny-dangerous.sh
function guardPath(): string {
  const override = process.env.DENY_DANGEROUS_GUARD;
  if (typeof override === "string" && override.length > 0) {
    return override;
  }
  const pluginFile = realpathSync(fileURLToPath(import.meta.url));
  return join(dirname(pluginFile), "..", "hooks", "deny-dangerous.sh");
}

export const DenyDangerous: Plugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") {
        return;
      }
      const command: unknown = (output as { args?: { command?: unknown } } | null | undefined)?.args
        ?.command;
      if (typeof command !== "string" || command.trim().length === 0) {
        throw new Error("deny-dangerous: missing bash command data; blocking tool call (fail closed)");
      }
      let result;
      try {
        result = spawnSync(guardPath(), [], {
          input: command,
          encoding: "utf8",
          timeout: 15000,
          maxBuffer: 64 * 1024,
        });
      } catch (error) {
        throw new Error(`deny-dangerous: guard did not start (${String(error)}); blocking (fail closed)`);
      }
      if (result.error != null) {
        throw new Error(
          `deny-dangerous: guard spawn failed (${String(result.error.message ?? result.error)}); blocking (fail closed)`,
        );
      }
      if (result.status !== 0) {
        const reason = typeof result.stderr === "string" ? result.stderr.trim() : "";
        throw new Error(
          reason.length > 0
            ? `deny-dangerous: ${reason}`
            : "deny-dangerous: guard blocked the command; blocking tool call (fail closed)",
        );
      }
      // Guard exited 0: allow the tool call to continue unchanged.
    },
  };
};
