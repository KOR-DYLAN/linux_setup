TFTP_DIR=/tftpboot
NFS_DIR=/nfsroot
OPTION_DIR=/opt

echo "installing common packages..."
sudo apt update
sudo apt upgrade -y
sudo apt install    build-essential gcc-multilib g++-multilib gdb cmake llvm lldb clang \
                    libncurses5 libncurses5-dev libncursesw5 libncursesw5-dev bison flex u-boot-tools \
                    libssl-dev python3-dev python2.7-dev net-tools git vim neovim unzip font-manager \
                    libx11-dev libx11-6:i386 mkisofs powerline neovim curl barrier ssh imwheel meson tree \
					qemu qemu-system qemu-system-arm qemu-efi qemu-efi-arm qemu-efi-aarch64 qemu-kvm \
					qemu-system-common qemu-system-data qemu-system-gui qemubuilder qemu-user qemu-user-binfmt qemu-utils -y

echo "configuring ssh..."
ssh-keygen -t rsa -f /home/$USER/.ssh/id_rsa -q -P ""
touch /home/$USER/.ssh/authorized_keys
touch /home/$USER/.ssh/known_hosts
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/id_rsa
chmod 644 /home/$USER/.ssh/id_rsa.pub
chmod 644 /home/$USER/.ssh/authorized_keys
chmod 644 /home/$USER/.ssh/known_hosts

echo "installing i386 packages..."
sudo dpkg --add-architecture i386
sudo apt list --upgradable
sudo apt-get update
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 -y

mkdir -p ~/.config
git clone https://github.com/KOR-DYLAN/nvim.git ~/.config/
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

echo "configuring git..."
echo "input your git name: "
read git_name
echo "input your git e-mail: "
read git_e_mail
git config --global user.name "$git_name"
git config --global user.email $git_e_mail
git config --global core.autocrlf input

echo "configuring tftp..."
sudo mkdir -p $TFTP_DIR
sudo chown $USER:$USER $TFTP_DIR
sudo apt install tftp tftpd xinetd -y
sudo test -e "/etc/xinetd.d/tftp" && sudo cp /etc/xinetd.d/tftp /etc/xinetd.d/tftp_backup
echo -e "service tftp
{
	socket_type = dgram
	protocol = udp
	wait = yes
	user = $USER
	server = /usr/sbin/in.tftpd
	server_args = -s $TFTP_DIR
	disable = no
	per_source = 11
	cps = 100 2
	flags =IPv4
}" | sudo tee -a /etc/xinetd.d/tftp > /dev/null
sudo service xinetd restart

echo "configuring nfs..."
sudo mkdir -p $NFS_DIR
sudo chown $USER:$USER $NFS_DIR
sudo apt install nfs-kernel-server -y
sudo test -e "/etc/exports" && sudo cp /etc/exports /etc/exports_backup
sudo echo "$NFS_DIR *(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports > /dev/null
sudo service nfs-kernel-server restart

echo "installing samba..."
sudo apt-get install samba -y
echo sudo smbpasswd -a $USER
sudo smbpasswd -a $USER
sudo test -e "/etc/samba/smb.conf" && sudo cp /etc/samba/smb.conf /etc/samba/smb.conf_backup
echo -e "
[linux-server-$USER]
comment = $USER' shared directory
path = /
read only = no
writable = yes
guest ok = no
browsable = yes
valid user = $USER
create mask = 0644
directory mask = 0644" | sudo tee -a /etc/samba/smb.conf > /dev/null

sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh

mkdir ~/.poshthemes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
chmod u+rw ~/.poshthemes/*.omp.*
rm ~/.poshthemes/themes.zip

echo "set .bashrc"
echo "" >> ~/.bashrc
echo "# oh-my-posh" >> ~/.bashrc
echo "eval \"\$(oh-my-posh init bash --config ~/.poshthemes/amro.omp.json)\"" >> ~/.bashrc
echo "" >> ~/.bashrc
echo "# alias" >> ~/.bashrc
echo alias vi=\"nvim\" >> ~/.bashrc
echo alias vim=\"nvim\" >> ~/.bashrc
echo alias sudo=\"sudo \" >> ~/.bashrc
source ~/.bashrc
