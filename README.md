# OPlus image utilities #

### Prerequisites ###
- Linux running kernel 5.4 or up (check with `uname -r`)

### Image rebuilding ###
- Used to rebuild read-only erofs images into EXT4 mountable images.
Usage:
` 
sudo ./erofs.sh <path to original image> <image partition name>
`
For example, if I'm trying to make system_ext image ext4, I'll use the following command:
`
sudo ./erofs.sh system_ext.img system_ext
`

### Product image rebuilding ###
- OPlus (previously oppo) has been being a jerk and adding a butt ton of useless so-called "optimizations" (porting killers). This is one of them.
- In Android 12 (OxygenOS 12 at least), OPlus has added `OPLUS_FEATURE_OVERLAY_MOUNT` to "mount product partition from existing my_* partitions" (to save image space? idk). With this going on, the product image shipped with OTAs is a dummy image that could not be mounted.
- Non-OPlus devices does NOT have `OPLUS_FEATURE_OVERLAY_MOUNT` implementation (and it is highly unrecommended to use it, as someone has bricked their devices before after implementing it). However, product image should NOT be empty (there is a system symlink pointing to `/product`). Therefore, this script is written to merge the my_* partitions into a single product image to replicate the `/product` behavior on OPlus devices.

Usage:
`
sudo ./product-merge.sh
`

### OPlus custom partition merging ###
- We will still have to merge my_* partitions after building the product image (as not all files exist in product image). The script will automatically merge the my_* partitions into system.

Usage:
`
sudo ./oplus-merge.sh
`

### Notes ###
- All images (especially system) must be the dir that the script is ran.

### To-Do ###
- Remove dependency of system file_contexts to build all images (we currently cat system filecontexts to the working file contexts to make the image resign properly)
- Run checks on mounting image (It is reported by [Velosh](https://github.com/velosh) that sometimes mounting erofs images without `-o loop -t erofs` does not work. However it works on my PC, that's why I introduced [this commit](https://github.com/JamieHoSzeYui/oplus-utils/commit/d6b9b3621847117ca60691bd3749d9107f10c1b3). Will work on checks for it later.)

### Credits and Thanks ###

[Amack](https://github.com/amackpro)

[Erfan Abdi](https://github.com/erfanoabdi)

[Velosh](https://github.com/velosh)

[Piraterex](https://github.com/piraterex)

[Xiaoxindada](https://github.com/xiaoxindada)

And all those I forgot to mention.