# TomThumb
Automatic external drive cacher for Debian-based linux https://joekoop.com/tomthumb

TomThumb is a BASH script that, when a USB stick is inserted, will smartly skip the files it can, and copy the USB stick to `~/.tomthumb/UUID=/$UUID/$DATE/` (example: `/home/joek/.tomthumb/UUID=/7A9D-5FEC/2019-08-16_21-49-20/`).

## Features

- Semi-automatic syncronizaion
- Seprate folders for different FSs of USB sticks (and optical discs)
- Seprate folders for different times of syncronization occuransences
- Uses `rsync` for syncing
- Uses `cp --hard` to sync only differences
- Uses `jdupes` to reduce space needed for cache

## Dependencies

- jdupes (recommended) `sudo apt install jdupes`
- rsync `sudo apt install rsync`
