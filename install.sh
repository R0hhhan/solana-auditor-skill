#!/bin/bash
# Solana Auditor Skill - Installer
# Installs the solana-auditor-skill into ~/.claude/skills/ (default) or custom path.
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR"

# Defaults
SKILLS_DIR="$HOME/.claude/skills"
SKILL_NAME="solana-auditor"
TARGET_PATH="$SKILLS_DIR/$SKILL_NAME"
USE_AGENTS=false
SKIP_CONFIRM=false

print_banner() {
    echo ""
    echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}                                                               ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${RED}███████╗ ${GREEN}██████╗  ${YELLOW}██╗      ${BLUE}█████╗ ${MAGENTA}███╗   ██╗ ${CYAN}█████╗${NC}     ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${RED}██╔════╝ ${GREEN}██╔══██╗ ${YELLOW}██║     ${BLUE}██╔══██╗${MAGENTA}████╗  ██║${CYAN}██╔══██╗${NC}    ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${RED}███████╗ ${GREEN}██║  ██║ ${YELLOW}██║     ${BLUE}███████║${MAGENTA}██╔██╗ ██║${CYAN}███████║${NC}    ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${RED}╚════██║ ${GREEN}██║  ██║ ${YELLOW}██║     ${BLUE}██╔══██║${MAGENTA}██║╚██╗██║${CYAN}██╔══██║${NC}    ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${RED}███████║ ${GREEN}██████╔╝ ${YELLOW}███████╗${BLUE}██║  ██║${MAGENTA}██║ ╚████║${CYAN}██║  ██║${NC}    ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${RED}╚══════╝ ${GREEN}╚═════╝  ${YELLOW}╚══════╝${BLUE}╚═╝  ╚═╝${MAGENTA}╚═╝  ╚═══╝${CYAN}╚═╝  ╚═╝${NC}    ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}                                                               ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${WHITE}Solana Auditor Skill — Full-Lifecycle Security${NC}              ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}                                                               ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${GREEN}▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄${NC}      ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${YELLOW}              Superteam Brazil${NC}                               ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}   ${GREEN}▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀${NC}      ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}                                                               ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_help() {
    echo "Solana Auditor Skill - Installer"
    echo ""
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Installs the solana-auditor-skill with progressive-loading skills,"
    echo "agents, commands, and auto-loading security rules."
    echo ""
    echo "Options:"
    echo "  -y, --yes              Skip confirmation prompt"
    echo "  --target <path>        Install to custom path (default: ~/.claude/skills/)"
    echo "  --agents               Install to .agents/ directory (for Codex, Cursor, etc.)"
    echo "  -h, --help             Show this help"
    echo ""
    echo "Examples:"
    echo "  ./install.sh                                    # Default install"
    echo "  ./install.sh --target ~/.claude/skills/         # Personal install"
    echo "  ./install.sh --target ./.claude/skills/          # Project install"
    echo "  ./install.sh --agents --target ./.agents/        # Non-Claude tools"
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            SKIP_CONFIRM=true
            shift
            ;;
        --target)
            SKILLS_DIR="$2"
            TARGET_PATH="$SKILLS_DIR/$SKILL_NAME"
            shift 2
            ;;
        --agents)
            USE_AGENTS=true
            shift
            ;;
        -h|--help)
            print_banner
            print_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_help
            exit 1
            ;;
    esac
done

print_banner

echo -e "${CYAN}Installing Solana Auditor Skill...${NC}"
echo ""

# Confirm
if [ "$SKIP_CONFIRM" = false ]; then
    echo -e "Target: ${WHITE}$TARGET_PATH${NC}"
    echo -e "Agents mode: ${WHITE}$USE_AGENTS${NC}"
    echo ""
    read -p "Proceed with installation? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        echo -e "${YELLOW}Installation cancelled.${NC}"
        exit 0
    fi
fi

# Remove existing installation if present
if [ -d "$TARGET_PATH" ]; then
    echo -e "  ${YELLOW}→${NC} Removing existing installation at $TARGET_PATH"
    rm -rf "$TARGET_PATH"
fi

# Create target directory
mkdir -p "$TARGET_PATH"

# Install skill files
echo -e "${CYAN}[1/4]${NC} Installing skill files..."
for item in "$SOURCE_DIR/skill"/*; do
    if [ -f "$item" ]; then
        cp "$item" "$TARGET_PATH/"
        echo -e "  ${GREEN}✓${NC} $(basename "$item")"
    fi
done

# Install agents
echo -e "${CYAN}[2/4]${NC} Installing agents..."
mkdir -p "$TARGET_PATH/agents"
for item in "$SOURCE_DIR/agents"/*; do
    if [ -f "$item" ]; then
        cp "$item" "$TARGET_PATH/agents/"
        echo -e "  ${GREEN}✓${NC} agents/$(basename "$item")"
    fi
done

# Install commands
echo -e "${CYAN}[3/4]${NC} Installing commands..."
mkdir -p "$TARGET_PATH/commands"
for item in "$SOURCE_DIR/commands"/*; do
    if [ -f "$item" ]; then
        cp "$item" "$TARGET_PATH/commands/"
        echo -e "  ${GREEN}✓${NC} commands/$(basename "$item")"
    fi
done

# Install rules
echo -e "${CYAN}[4/4]${NC} Installing rules..."
mkdir -p "$TARGET_PATH/rules"
for item in "$SOURCE_DIR/rules"/*; do
    if [ -f "$item" ]; then
        cp "$item" "$TARGET_PATH/rules/"
        echo -e "  ${GREEN}✓${NC} rules/$(basename "$item")"
    fi
done

# Install CLAUDE.md if not in agents mode
if [ "$USE_AGENTS" = false ]; then
    CLAUDE_MD_DEST="$HOME/.claude/CLAUDE.md"
    if [ -f "$CLAUDE_MD_DEST" ]; then
        echo -e "  ${YELLOW}→${NC} Existing CLAUDE.md found — skill CLAUDE.md copied to $TARGET_PATH/CLAUDE.md"
        cp "$SOURCE_DIR/CLAUDE.md" "$TARGET_PATH/CLAUDE.md"
    else
        cp "$SOURCE_DIR/CLAUDE.md" "$CLAUDE_MD_DEST"
        echo -e "  ${GREEN}✓${NC} CLAUDE.md installed to $CLAUDE_MD_DEST"
    fi
else
    cp "$SOURCE_DIR/CLAUDE.md" "$TARGET_PATH/CLAUDE.md"
    echo -e "  ${GREEN}✓${NC} CLAUDE.md installed to $TARGET_PATH/CLAUDE.md"
fi

# Also mirror to .codex if codex CLI is detected
if command -v codex &> /dev/null; then
    CODEX_SKILLS_DIR="$HOME/.codex/skills/$SKILL_NAME"
    mkdir -p "$CODEX_SKILLS_DIR"
    cp -r "$TARGET_PATH"/* "$CODEX_SKILLS_DIR/"
    echo -e "  ${GREEN}✓${NC} Mirrored to $CODEX_SKILLS_DIR (codex detected)"
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}Installation Complete!${NC}                                          ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${WHITE}Installed:${NC}"
echo -e "  ${GREEN}✓${NC} solana-auditor-skill  ${CYAN}$TARGET_PATH${NC}"
echo ""
echo -e "${CYAN}Try asking Claude:${NC}"
echo -e "  ${BLUE}•${NC} \"Audit my Anchor program\""
echo -e "  ${BLUE}•${NC} \"Run a quick security scan\""
echo -e "  ${BLUE}•${NC} \"Check my program for reentrancy vulnerabilities\""
echo -e "  ${BLUE}•${NC} \"Simulate a flash-loan attack on my protocol\""
echo -e "  ${BLUE}•${NC} \"Generate an audit report\""
echo ""
echo -e "${CYAN}Commands:${NC}"
echo -e "  ${BLUE}•${NC} /audit, /quick-scan, /deep-review, /threat-model"
echo -e "  ${BLUE}•${NC} /economic-sim, /audit-report, /fix-findings"
echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}            Powered by Superteam Brazil${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""