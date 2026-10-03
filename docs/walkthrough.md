# Next Goal - TUI Implementation Walkthrough

Here is a summary of the work we completed to design and scaffold the **Next Goal** application based on our agreed-upon plan.

## 1. Architectural Plan
We defined an architecture that centers around a minimal Terminal UI client with support for four distinct views (Next Goal Focus, Prioritized Backlog, Kanban, and Hierarchy) and a future Kafka-based backend with Calendar integration.

## 2. Project Scaffolding (`cabal init`)
We initialized the Haskell project inside `tui/` and implemented the foundational `Brick` and `RIO` code:
- **Domain Models (`Types.hs`)**: Defined `Goal`, `GoalStatus`, and `Page` views.
- **Application State (`State.hs`)**: Created `AppState` to track current goals, routing, and global text inputs.
- **Event Loop (`Event.hs`)**: Hooked up global keybindings (`1-4` for navigation, `h` for help, `n` for new goal).
- **Presentation (`Draw.hs`)**: Implemented rendering logic for the four pages and the global goal creation overlay modal.

## 3. UI Enhancements
- Added a **Help Page** (`h`) to display all active shortcuts.
- Added a dynamic **Footer Widget** that lists available pages and highlights the currently active page.

## 4. Local Persistence (`aeson`)
- **Storage Layer (`Store.hs`)**: Wrote logic to load and save the goal list into a local `goals.json` file on disk.
- Connected the `Store` functions into the `Brick` event loop. When you create a new goal via the `n` modal, it immediately saves to disk and updates the `AppState`, making the goals instantly visible on the Backlog and Next Goal pages.

## Next Steps
You can run the application locally using Nix to test out the UI and start adding your own goals!
```bash
nix develop --command cabal run next-goal-tui
```
