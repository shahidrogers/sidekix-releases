# Sidekix downloads

Sidekix is a narrow instrument strip for the edge of your Mac, designed and developed by [Lutsinar Labs](https://lutsinar.com/).

## Download

Get the latest Apple Silicon build from [Releases](https://github.com/shahidrogers/sidekix-releases/releases/latest).

Sidekix is currently a free, unsigned beta. macOS will block its first launch because the app is not yet notarized:

1. Unzip Sidekix and move `Sidekix.app` to Applications.
2. Try to open it once.
3. Open **System Settings → Privacy & Security** and scroll to Security.
4. Click **Open Anyway** for Sidekix, then confirm **Open**.

### Terminal alternative

If you are comfortable using Terminal, after moving Sidekix to Applications you can remove macOS's download quarantine and launch it with:

```sh
xattr -dr com.apple.quarantine /Applications/Sidekix.app
open /Applications/Sidekix.app
```

Only run these commands for a copy downloaded from this repository.

Only download Sidekix from this repository. Each release includes a SHA-256 checksum for verifying the downloaded ZIP.

## System requirements

- macOS 14 or later
- Apple Silicon Mac

The application source is maintained privately by Lutsinar Labs.

Copyright © 2026 Lutsinar Labs. All rights reserved.
