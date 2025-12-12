# this is based on 
mkdir linux-rust-demo
cd linux-rust-demo
# wget https://cdimage.debian.org/images/cloud/bookworm/20250316-2053/debian-12-nocloud-amd64-20250316-2053.qcow2 - a bit outdated
# note that ubuntu does not come with default username:password, so we need to create some init files for it to work

# copy this to user-data
#cloud-config
users:
  - default
chpasswd:
  list: |
    ubuntu:ubuntu
  expire: false
ssh_pwauth: true

# copy this to meta-data
instance-id: iid-12345

# create seed.iso file
cloud-localds seed.iso user-data meta-data

# wget https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img - 24.04
wget https://cloud-images.ubuntu.com/plucky/current/plucky-server-cloudimg-amd64.img # - 25.04

qemu-img resize plucky-server-cloudimg-amd64.img +32G

# note that we added the seed.iso 
qemu-system-x86_64 -m 8G -M q35 -accel kvm -smp 8 -hda plucky-server-cloudimg-amd64.img -drive if=virtio,format=raw,file=seed.iso -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp:127.0.0.1:5555-:22 -nographic -serial telnet:localhost:4321,server,wait


# on another terminal
telnet localhost 4321
ubuntu:ubuntu
sudo apt update
# sudo apt install fdisk
# sudo cfdisk /dev/*da - no need over here apparantly

# Once in cfdisk, use the arrow keys to select [ Sort ], then select the root filesystem (the bottom one) and pick [ Resize ], then [ Write ], and [ Quit ]. You'll need to type yes in response to [ Write ]. then quit
reboot

# df -h
# /dev/sda3        35G  1.2G   32G   4% / - something like this



# install some tools
sudo apt install build-essential libssl-dev python3 flex bison bc libncurses-dev gawk openssl libssl-dev libelf-dev libudev-dev libpci-dev libiberty-dev autoconf llvm clang lld git
sudo curl https://sh.rustup.rs | bash
source $HOME/.cargo/env
cargo install --locked bindgen-cli
rustup component add rust-src


# install linux kernel - a note over here, I have done with linux-6.14 and there was some problems later on, so I am going to newer kernel.
# this is the neweset one according to nov 19, so lets use it 
curl -O https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.17.8.tar.xz
tar xvf linux-6.17.8.tar.xz
cd linux-6.17.8
make LLVM=1 rustavailable
make LLVM=1 defconfig
# General setup / Rust support
make LLVM=1 menuconfig



# build kernel
make LLVM=1 -j8
sudo make LLVM=1 modules_install
sudo make LLVM=1 install
make LLVM=1 rust-analyzer
sudo reboot


# Task 7 - Build a kernel module

git clone https://github.com/Rust-for-Linux/rust-out-of-tree-module
cd rust-out-of-tree-module
# git checkout 15de8569df46e16f4940b52c91ee8f6bfbe5ab22
make KDIR=../linux-6.17.8 LLVM=1


# running module
sudo insmod rust_out_of_tree.ko
sudo dmesg
# [ 3441.273361] rust_out_of_tree: loading out-of-tree module taints kernel.
# [ 3441.273576] rust_out_of_tree: Rust out-of-tree sample (init)

sudo rmmod rust_out_of_tree
# [ 3486.812521] rust_out_of_tree: My numbers are [72, 108, 200]
# [ 3486.812526] rust_out_of_tree: Rust out-of-tree sample (exit)


# working over vs code 
# sudo apt install openssh-server

# shay@shay-System-Product-Name ~/c/linux-rust-demo> cat ~/.ssh/id_ed25519.pub
# copy to here
vim ~/.ssh/authorized_keys


# this should work now
# for debugging - sudo systemctl enable ssh - sudo systemctl start ssh - sudo systemctl status ssh 
ssh -p 5555 ubuntu@localhost


if one working over vscode


then in .vscode/settings.json
{
    "rust-analyzer.linkedProjects": [
        "rust-project.json"
    ],
    // CRITICAL: Prevent rust-analyzer from looking for the standard library.
    "rust-analyzer.cargo.sysroot": null, 
    
    // 1. Enable checking on save (must be a boolean: true or false)
    "rust-analyzer.checkOnSave": true, 

    // 2. Define the tool to use when checking (e.g., "clippy" for linting)
    "rust-analyzer.check.command": "clippy"
}


if working over zed
ctrl+shift+p, zed: open server settings (make sure server open on rust-out-of-tree-module directory)

{
  "lsp": {
    "rust-analyzer": {
      "initialization_options": {
        "linkedProjects": [
          "rust-project.json"
        ]
      }
    }
  }
}
