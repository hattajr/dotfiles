#!/usr/bin/env bash
# Static shortcut hints rendered as a dracula `custom:` status segment.
# Keys in dracula purple, labels white, thin dividers between groups.
# %% emits a literal % (tmux/printf would otherwise treat it specially).
printf '#[fg=#bd93f9]"/%% #[fg=#f8f8f2]split #[fg=#6272a4]│ #[fg=#bd93f9]d #[fg=#f8f8f2]detach #[fg=#6272a4]│ #[fg=#bd93f9]hjkl #[fg=#f8f8f2]pane #[fg=#6272a4]│ #[fg=#bd93f9]C-hjkl #[fg=#f8f8f2]resize'
