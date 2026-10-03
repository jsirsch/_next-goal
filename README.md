# Next Goal

`next-goal` is an application ecosystem designed to help you track and focus on your immediate next goal. This repository is structured as a monorepo containing the various components of the application.

## Components

Currently planned and implemented components:

- **[`tui/`](tui/)**: A terminal user interface (TUI) client built in Haskell using the Brick and RIO libraries.
- *(Future)* **Backend**: A Kafka-based backend for event streaming and syncing goals.
- *(Future)* **Web UI**: A web-based frontend client.

## Setup & Development

This project uses [Nix](https://nixos.org/) for managing development environments and dependencies to ensure consistency across all components.

### Using Nix Flakes

If you have Nix with Flakes enabled, you can enter the unified development shell (which provides tools like GHC, Cabal, Haskell Language Server, and Vulnix) by running:

```bash
nix develop
```

You can also run security checks on the flake using the configured Vulnix app:

```bash
nix run .#vulnix-scan
```

*(For non-flake setups, `shell.nix` is provided for backward compatibility. Run `nix-shell`.)*

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
