#!/usr/bin/env node

/**
 * omu — oh-my-universal CLI
 *
 * Commands:
 *   omu setup    — Install skills into the current project
 *   omu doctor   — Check if skills are accessible
 *   omu list     — List all available skills
 *   omu link     — Symlink skills into current project
 */

import { existsSync, readdirSync, mkdirSync, copyFileSync, symlinkSync, readFileSync } from 'fs';
import { join, dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..');
const SKILLS_DIR = join(ROOT, 'skills');

const cmd = process.argv[2] || 'list';
const isTTY = process.stdout.isTTY;
const green = s => isTTY ? `\x1b[32m${s}\x1b[0m` : s;
const dim = s => isTTY ? `\x1b[2m${s}\x1b[0m` : s;

function listSkills() {
  const skills = readdirSync(SKILLS_DIR).filter(f => f.endsWith('.md')).sort();
  console.log(`\noh-my-universal — ${skills.length} skills available\n`);
  for (const skill of skills) {
    const name = skill.replace('.md', '');
    const content = readFileSync(join(SKILLS_DIR, skill), 'utf-8');
    const desc = content.match(/^>\s*(.+)/m)?.[1] || '';
    console.log(`  ${green(name.padEnd(22))} ${dim(desc.slice(0, 70))}`);
  }
  console.log(`\nUsage: add ${ROOT} to your AI CLI's project scope`);
  console.log(`  Copilot CLI: /add-dir ${ROOT}`);
  console.log(`  Claude Code: claude --plugin-dir ${ROOT}`);
  console.log(`  npm: npm i -g oh-my-universal && omu link\n`);
}

function setup() {
  const cwd = process.cwd();
  if (cwd === ROOT) {
    console.log('Already in oh-my-universal. Run this from your project directory.');
    process.exit(1);
  }

  // Copy the instructions file to the project
  const targetDir = join(cwd, '.github', 'instructions');
  mkdirSync(targetDir, { recursive: true });
  const src = join(ROOT, '.github', 'instructions', 'skills.instructions.md');
  const dst = join(targetDir, 'omu-skills.instructions.md');

  if (existsSync(src)) {
    copyFileSync(src, dst);
    console.log(`${green('✓')} Copied skill instructions to ${dst}`);
  }

  // Copy AGENTS.md reference if no AGENTS.md exists
  if (!existsSync(join(cwd, 'AGENTS.md'))) {
    copyFileSync(join(ROOT, 'AGENTS.md'), join(cwd, 'AGENTS.md'));
    console.log(`${green('✓')} Created AGENTS.md with skill references`);
  }

  console.log(`\n${green('Setup complete!')} Skills are now available in this project.`);
  console.log(`Skills source: ${ROOT}`);
}

function doctor() {
  console.log('\noh-my-universal doctor\n');
  const checks = [
    { label: 'Skills directory', check: () => existsSync(SKILLS_DIR) },
    { label: 'Copilot adapter', check: () => existsSync(join(ROOT, '.github', 'instructions', 'skills.instructions.md')) },
    { label: 'Claude adapter', check: () => existsSync(join(ROOT, '.claude', 'skills', 'oh-my-universal', 'SKILL.md')) },
    { label: 'Cursor adapter', check: () => existsSync(join(ROOT, '.cursor', 'rules', 'skills.mdc')) },
    { label: 'Windsurf adapter', check: () => existsSync(join(ROOT, '.windsurfrules')) },
    { label: 'AGENTS.md', check: () => existsSync(join(ROOT, 'AGENTS.md')) },
    { label: 'CLAUDE.md', check: () => existsSync(join(ROOT, 'CLAUDE.md')) },
  ];

  let pass = 0;
  for (const { label, check } of checks) {
    const ok = check();
    console.log(`  ${ok ? green('✓') : '✗'} ${label}`);
    if (ok) pass++;
  }

  const skills = readdirSync(SKILLS_DIR).filter(f => f.endsWith('.md'));
  console.log(`\n  ${green('✓')} ${skills.length} skills available`);
  console.log(`\nResult: ${pass}/${checks.length} adapters ready\n`);
}

function link() {
  const cwd = process.cwd();
  const target = join(cwd, '.omu-skills');
  if (existsSync(target)) {
    console.log('Skills already linked at .omu-skills/');
    process.exit(0);
  }
  try {
    symlinkSync(SKILLS_DIR, target, 'junction');
    console.log(`${green('✓')} Linked skills to ${target}`);
    console.log('AI agents can now read skills from .omu-skills/');
  } catch (e) {
    console.error(`Failed to create symlink: ${e.message}`);
    console.log('Try running as administrator, or use: omu setup');
  }
}

switch (cmd) {
  case 'list': listSkills(); break;
  case 'setup': setup(); break;
  case 'doctor': doctor(); break;
  case 'link': link(); break;
  default:
    console.log(`Unknown command: ${cmd}`);
    console.log('Available: list, setup, doctor, link');
}
