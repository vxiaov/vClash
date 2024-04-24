# U盘使用方法总结

> 一个32GB的 USB3.2 高速U盘可以帮你解决路由器的诸多问题。

1. 路由器存储空间很小（写入次数多了容易坏掉，路由器寿命缩短），此时通过外置U盘接管，坏了U盘再换一个而已。
2. 内存很小，运行大的程序可能会失败，此时U盘新建一个swap分区，给路由器挂载一个虚拟内存，大程序的运行也不是问题了。



## U盘如何分区

建议：
- swap分区: 1GB
- ext3分区: 10GB+(剩余空间),不建议使用vfat分区（虽然这样的分区在Windows上很好用，但在linux上是有局限性的)


分区命令(路由器自带): `fdisk`

首先，假设我们的U盘设备路径为`/dev/sda` , 使用fdisk 创建分区表如下:
```bash
myrouter@RT-AC86U-3418:~# fdisk -l /dev/sda

Disk /dev/sda: 31.0 GB, 31004295168 bytes
64 heads, 32 sectors/track, 29568 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes

   Device Boot      Start         End      Blocks  Id System
/dev/sda1               1         955      977904  82 Linux swap
/dev/sda2             956       29568    29299712   c Win95 FAT32 (LBA)
```

创建分区文件系统的方法：

```bash

mkswap /dev/sda1
mkfs.ext3 /dev/sda2

```


如此，我们就创建好了U盘的分区，接下来，我们就开始用U盘保护路由器。

## U盘挂载路由器虚拟内存


挂载swap交换区（虚拟内存）很容易：

```bash

swapon /dev/sda1

```


## 替换/koolshare分区为U盘分区
> 替换/koolshare 分区的目的： 1.减少对路由器存储芯片写入操作（延长路由器使用寿命）, 2.给/koolshare分区扩容，/jffs分区总容量 47.0M ,只有25M 可以使用，安装一两个插件就控件不足了。

1. U盘分区: 包括利用`fdisk`命令给U盘分区（swap交换区1GB控件 /dev/sda1，剩余空间作为ext3分区 /dev/sda2)
2. 创建文件系统: mkswap /dev/sda1  , mkfs.ext3 /dev/sda2 
3. 拷贝/koolshare 目录内容： `mkdir /mnt/temp && mount /dev/sda2 /mnt/temp && cp -rp /koolshare/.[sv]* /koolshare/* /mnt/temp/ ; umount /dev/sda2`
4. 挂载 /dev/sda2 到 /koolshare 目录： `mount /dev/sda2 /koolshare`



挂载并替换`koolshare`这一步骤需要详细说明，因为我们需要下次启动时，自动完成挂载分区操作：
- 写一个分区挂载脚本 S03MountClash.sh：当检测到了 /dev/sda2 分区可读时，自动挂载到 /koolshare 目录
- 将 S03MountClash.sh 脚本文件存放到: /koolshare/init.d/ 目录下，记住 /dev/sda2 分区和原来的 /koolshare/init.d 目录都要保存一份。

> 挂载虚拟内存的操作也要写一个脚本S02MountSwap.sh，用于启动路由器时自动挂载虚拟内存。 


## 总结

以上提到的两个脚本都已经在项目的 clash/clash/init.d/ 目录下提供了示例。

我们可以通过软链接方式或者复制方式，将这两个文件添加到 /koolshare/init.d/ 目录下即可在路由器重启后自动挂载U盘分区。



