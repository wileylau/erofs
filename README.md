# erofs to ext4 #

### Usage: ###

` 
sudo ./erofs.sh <path to original image> <image partition name>
`

For example, if I'm trying to make product.img ext4, I'll use the following command:

`
sudo ./erofs.sh product.img product
`

You can also define specific partition size.
Let's say I'm trying to build a 900MB system_ext image, I'll use the following command:

`
sudo ./erofs.sh system_ext.img system_ext 943718400
`

Note that the size value is in bytes.


### Notes ###

- all images (especially system) must be the dir that the script is ran.

### To-Do ###

- Remove dependency of system file_contexts to build all images (we currently cat system filecontexts to the working file contexts to make the image resign properly)

### Credits and Thanks ###

[Amack](https://github.com/amackpro)

[Erfan Abdi](https://github.com/erfanoabdi)

[Velosh](https://github.com/velosh)

[Piraterex](https://github.com/piraterex)

And all those I forgot to mention.