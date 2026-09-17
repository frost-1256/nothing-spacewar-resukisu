> [!IMPORTANT]
> **This is an unofficial fork** of `NothingOSS/android_kernel_msm-5.4_nothing_sm7325`
> that backports [susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu) **v2.x** to the
> Nothing Phone (1) (Spacewar, SM7325 / msm-5.4 qGKI) kernel, together with a
> KernelSU driver.
> Upstream release notes follow below.

# Spacewar SUSFS v2 kernel (msm-5.4 qGKI)

Custom kernel for the Nothing Phone (1) with SUSFS v2 backported to Linux 5.4 and a
KernelSU-based root driver.

## Features

- Linux **5.4.289** qGKI (`sm7325/v/mr`), built with the stock config
  (`vendor/spacewar-stock_defconfig`) + the stock clang `r383902b` + ARM GNU 14.2.
- **SUSFS v2.3.0** (susfs4ksu `gki-android12-5.10`) hand-ported to 5.4:
  `SUS_PATH`, `SUS_MOUNT`, `SUS_KSTAT`, `SPOOF_UNAME`, `ENABLE_LOG`,
  `HIDE_KSU_SUSFS_SYMBOLS`, `SPOOF_CMDLINE_OR_BOOTCONFIG`, `SUS_MAP`, `OPEN_REDIRECT`.
- **ReSukiSU** root driver (built-in, manual-hook mode) — recommended on 5.4 because the
  upstream SukiSU 4.2.0 manager refuses non-GKI kernels.
- KMI-neutral: no existing header or exported prototype is changed (module CRCs unaffected).

## Variants

| variant | root driver | manager APK | config | build script |
|---|---|---|---|---|
| `v4` (default) | ReSukiSU `main` (submodule `KernelSU/`) | ReSukiSU v4.2.0-rc2 (code 35144) | `arch/arm64/configs/resukisu.config` | `build_5.4_resukisu.sh` |
| `v155` (legacy) | SukiSU `v3.1.4` + SUSFS v1.5.5 | SukiSU_v3.1.4_12960 | `arch/arm64/configs/sukisu.config` | see `docs/patches/v155/` |

## Build

```bash
# kernel root = this repository
./build_5.4_resukisu.sh          # -> build/Image
```

The script fetches the toolchain into `~/toolchains` on first run (Snapdragon clang is
not used here; the stock clang r383902b + ARM GNU 14.2 recipe is used) and merges
`vendor/spacewar-stock_defconfig` + `resukisu.config`.

## Create flashable artifacts

Provide your own stock boot image (extracted from your Nothing OS 3.2 firmware) and then:

```bash
STOCK_BOOT=/path/to/stock_boot.img ./repack-boot.sh v4
# -> Spacewar-boot-resukisu.img
# -> Spacewar-ReSukiSU-SUSFSv2-5.4.289.zip   (AnyKernel3)
```

## Flash

```bash
fastboot boot  Spacewar-boot-resukisu.img     # test first
fastboot flash boot_b Spacewar-boot-resukisu.img
```

Install the matching manager APK (`ReSukiSU_v4.2.0-rc2_35144`).

## Notes / limitations

- The v4 kernel's SUSFS v2 API answers both the SukiSU 4.2.0 and ReSukiSU managers; on a
  5.4 (non-GKI) device use **ReSukiSU**, whose manager reports the driver as working.
- In ReSukiSU manual-hook mode the kernel sucompat targets app processes (uid >= 10000);
  `adb shell su` is intentionally not handled.
- `open_redirect` is the only SUSFS v2 feature whose namei hooks were reduced for 5.4 in
  this port; all others are the full upstream logic.
- See `docs/` for the porting notes, the patch series and the verification logs
  (QEMU boot test, KMI audit, on-device results).

## Credits

- [simonpunk/susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu) — SUSFS
- [SukiSU-Ultra](https://github.com/SukiSU-Ultra/SukiSU-Ultra) / [ReSukiSU](https://github.com/ReSukiSU/ReSukiSU) — KernelSU fork and driver
- [osm0sis/AnyKernel3](https://github.com/osm0sis/AnyKernel3) — flashable zip template
- [ravindu644/Android-Kernel-Tutorials](https://github.com/ravindu644/Android-Kernel-Tutorials) — build scripts
- NothingOSS — original kernel source

## License

GPL-2.0 (see `COPYING`), same as the upstream kernel.
# NOTHING Phone(1) Release Note
01. NOS 3.0(Spacewar-V3.0-250108-1938)
  - The opensource of the initial release
  - devicetree
     Both of repository has moved to vendor/qcom/proprietary/devicetree/msm-extra in NOTHING opensource.
     Please make sure the path of vendor_links is correct when you lunch and building image
      - vendor/qcom/proprietary/camera-devicetree/
      - vendor/qcom/proprietary/display-devicetree/display
  - Supplementary note: Please verify the soft link yourself.
    Qualcomm's original design
    There is a symbolic link named 'vendor' in msm-5.4/arch/arm64/boot/dts/ that points to 'devicetree'.
    msm-5.4/arch/arm64/boot/dts/vendor -> vendor/qcom/proprietary/devicetree

02. NOS 3.0(Spacewar-V3.0-250218-1552)
  - No update

03. NOS 3.0(Spacewar-V3.0-250303-1817)
  - No update

04. NOS 3.0(Spacewar-V3.0-250409-2129)
  - No update

05. NOS 3.2(Spacewar-V3.2-250610-1104)
  - No update

06. NOS 3.2(Spacewar-V3.2-250701-1737)
  - No update

07. NOS 3.2(Spacewar-V3.2-250804-2110)
  - No update

08. NOS 3.2(Spacewar-V3.2-250926-1631)
  - No update

09. NOS 3.2(Spacewar-V3.2-251219-1652)
  - Update msm-5.4

10. NOS 3.2(Spacewar-V3.2-260206-1016)
  - No update

11. NOS 3.2(Spacewar-V3.2-260416-1140)
  - No update

12. NOS 3.2(Spacewar-V3.2-260618-1045)
  - No update

# How do I submit patches to Android Common Kernels

1. BEST: Make all of your changes to upstream Linux. If appropriate, backport to the stable releases.
   These patches will be merged automatically in the corresponding common kernels. If the patch is already
   in upstream Linux, post a backport of the patch that conforms to the patch requirements below.

2. LESS GOOD: Develop your patches out-of-tree (from an upstream Linux point-of-view). Unless these are
   fixing an Android-specific bug, these are very unlikely to be accepted unless they have been
   coordinated with kernel-team@android.com. If you want to proceed, post a patch that conforms to the
   patch requirements below.

# Common Kernel patch requirements

- All patches must conform to the Linux kernel coding standards and pass `script/checkpatch.pl`
- Patches shall not break gki_defconfig or allmodconfig builds for arm, arm64, x86, x86_64 architectures
(see  https://source.android.com/setup/build/building-kernels)
- If the patch is not merged from an upstream branch, the subject must be tagged with the type of patch:
`UPSTREAM:`, `BACKPORT:`, `FROMGIT:`, `FROMLIST:`, or `ANDROID:`.
- All patches must have a `Change-Id:` tag (see https://gerrit-review.googlesource.com/Documentation/user-changeid.html)
- If an Android bug has been assigned, there must be a `Bug:` tag.
- All patches must have a `Signed-off-by:` tag by the author and the submitter

Additional requirements are listed below based on patch type

## Requirements for backports from mainline Linux: `UPSTREAM:`, `BACKPORT:`

- If the patch is a cherry-pick from Linux mainline with no changes at all
    - tag the patch subject with `UPSTREAM:`.
    - add upstream commit information with a `(cherry-picked from ...)` line
    - Example:
        - if the upstream commit message is
```
        important patch from upstream

        This is the detailed description of the important patch

        Signed-off-by: Fred Jones <fred.jones@foo.org>
```
        - then Joe Smith would upload the patch for the common kernel as
```
        UPSTREAM: important patch from upstream

        This is the detailed description of the important patch

        Signed-off-by: Fred Jones <fred.jones@foo.org>

        Bug: 135791357
        Change-Id: I4caaaa566ea080fa148c5e768bb1a0b6f7201c01
        (cherry-picked from c31e73121f4c1ec41143423ac6ce3ce6dafdcec1)
        Signed-off-by: Joe Smith <joe.smith@foo.org>
```

- If the patch requires any changes from the upstream version, tag the patch with `BACKPORT:`
instead of `UPSTREAM:`.
    - use the same tags as `UPSTREAM:`
    - add comments about the changes under the `(cherry-picked from ...)` line
    - Example:
```
        BACKPORT: important patch from upstream

        This is the detailed description of the important patch

        Signed-off-by: Fred Jones <fred.jones@foo.org>

        Bug: 135791357
        Change-Id: I4caaaa566ea080fa148c5e768bb1a0b6f7201c01
        (cherry-picked from c31e73121f4c1ec41143423ac6ce3ce6dafdcec1)
        [ Resolved minor conflict in drivers/foo/bar.c ]
        Signed-off-by: Joe Smith <joe.smith@foo.org>
```

## Requirements for other backports: `FROMGIT:`, `FROMLIST:`,

- If the patch has been merged into an upstream maintainer tree, but has not yet
been merged into Linux mainline
    - tag the patch subject with `FROMGIT:`
    - add info on where the patch came from as `(cherry picked from commit <sha1> <repo> <branch>)`. This
must be a stable maintainer branch (not rebased, so don't use `linux-next` for example).
    - if changes were required, use `BACKPORT: FROMGIT:`
    - Example:
        - if the commit message in the maintainer tree is
```
        important patch from upstream

        This is the detailed description of the important patch

        Signed-off-by: Fred Jones <fred.jones@foo.org>
```
        - then Joe Smith would upload the patch for the common kernel as
```
        FROMGIT: important patch from upstream

        This is the detailed description of the important patch

        Signed-off-by: Fred Jones <fred.jones@foo.org>

        Bug: 135791357
        (cherry picked from commit 878a2fd9de10b03d11d2f622250285c7e63deace
         https://git.kernel.org/pub/scm/linux/kernel/git/foo/bar.git test-branch)
        Change-Id: I4caaaa566ea080fa148c5e768bb1a0b6f7201c01
        Signed-off-by: Joe Smith <joe.smith@foo.org>
```


- If the patch has been submitted to LKML, but not accepted into any maintainer tree
    - tag the patch subject with `FROMLIST:`
    - add a `Link:` tag with a link to the submittal on lore.kernel.org
    - if changes were required, use `BACKPORT: FROMLIST:`
    - Example:
```
        FROMLIST: important patch from upstream

        This is the detailed description of the important patch

        Signed-off-by: Fred Jones <fred.jones@foo.org>

        Bug: 135791357
        Link: https://lore.kernel.org/lkml/20190619171517.GA17557@someone.com/
        Change-Id: I4caaaa566ea080fa148c5e768bb1a0b6f7201c01
        Signed-off-by: Joe Smith <joe.smith@foo.org>
```

## Requirements for Android-specific patches: `ANDROID:`

- If the patch is fixing a bug to Android-specific code
    - tag the patch subject with `ANDROID:`
    - add a `Fixes:` tag that cites the patch with the bug
    - Example:
```
        ANDROID: fix android-specific bug in foobar.c

        This is the detailed description of the important fix

        Fixes: 1234abcd2468 ("foobar: add cool feature")
        Change-Id: I4caaaa566ea080fa148c5e768bb1a0b6f7201c01
        Signed-off-by: Joe Smith <joe.smith@foo.org>
```

- If the patch is a new feature
    - tag the patch subject with `ANDROID:`
    - add a `Bug:` tag with the Android bug (required for android-specific features)

# Vibrator driver for HHG device
## How to merge the driver into kernel source tree

 1. Copy \${this_project}/drivers/hid/hid-aksys.c into \${your_kernel_root}/drivers/hid/

 2. Compare and merge \${this_project}/drivers/hid/hid-ids.h into \${your_kernel_root}/drivers/hid/hid-ids.h :
 Add the following code before the last line of this file

    ```c
		#define USB_VENDER_ID_QUALCOMM  0x0a12
		#define USB_VENDER_ID_TEMP_HHG_AKSY 0x1234
		#define USB_PRODUCT_ID_AKSYS_HHG  0x1000
    ```

 3. Merge \${this_project}/drivers/hid/Kconfig into \${your_kernel_root}/drivers/hid/Kconfig :
Add the following code before the last line of this file

		config HID_AKSYS_QRD
    		tristate "AKSys gamepad USB adapter support"
    		depends on HID
    		---help---
    		Support for AKSys gamepad USB adapter

    	config AKSYS_QRD_FF
    		bool "AKSys gamepad USB adapter force feedback support"
    		depends on HID_AKSYS_QRD
    		select INPUT_FF_MEMLESS
    		---help---
    		Say Y here if you have a AKSys gamepad USB adapter and want to
    		enable force feedback support for it.
    		
 4. Merge \${this_project}/drivers/hid/Makefile into \${your_kernel_root}/drivers/hid/Makefile :
 Add the following code at the end of this file

		obj-$(CONFIG_HID_AKSYS_QRD)	+= hid-aksys.o
		
 5. Modify your kernel's default build configuration file. Add the following two lines:

        CONFIG_HID_AKSYS_QRD=m
        CONFIG_AKSYS_QRD_FF=y
