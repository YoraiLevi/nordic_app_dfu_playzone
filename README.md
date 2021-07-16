# nordic_app_dfu_playzone

* [nordic_app_dfu_playzone](#nordic_app_dfu_playzone)
  * [Summary](#summary)
  * [Requirements](#requirements)
  * [Flash Memory Layout](#flash-memory-layout)
  * [Procedures](#procedures)
    * [Using Examples](#using-examples)
      * [running app (only)](#running-app-only)
      * [running bootloader (only)](#running-bootloader-only)
        * [uploading dfu-bootloader image and performing dfu from phone](#uploading-dfu-bootloader-image-and-performing-dfu-from-phone)
    * [Building the bootloader ourselves](#building-the-bootloader-ourselves)
        * [creating private-public key pair](#creating-private-public-key-pair)
        * [flashing new bootloader](#flashing-new-bootloader)
        * [creating application update image and uploading from phone](#creating-application-update-image-and-uploading-from-phone)
    * [Flashing everything at one time](#flashing-everything-at-one-time)
      * [Debugging](#debugging)
    * [Private and Public keys (`nrfutil keys`)](#private-and-public-keys-nrfutil-keys)
      * [generating private key (`create_private_key.cmd`)](#generating-private-key-create_private_keycmd)
      * [generating public key for c usage (`create_public_key_c.cmd`)](#generating-public-key-for-c-usage-create_public_key_ccmd)
    * [Merging bootloader and an Application(+softdevice) images (`nrfutil settings`,`mergehex`)](#merging-bootloader-and-an-applicationsoftdevice-images-nrfutil-settingsmergehex)
      * [generating bootloader settings page](#generating-bootloader-settings-page)
    * [Performing DFU](#performing-dfu)
      * [Generating update packages (`nrfutil pkg`)](#generating-update-packages-nrfutil-pkg)
      * [Uploading bootloader and flashing application through phone](#uploading-bootloader-and-flashing-application-through-phone)
      * [Uploading bootloader and flashing application through PC](#uploading-bootloader-and-flashing-application-through-pc)
  * [References](#references)
    * [Documentation regarding nordic's DFU](#documentation-regarding-nordics-dfu)

## Summary

from the root folder of this repo run(where this README.md is located):

```diff
--create powershell scripts for the entire process?
```

```cmd
.\compile.cmd
.\nordic_packaging_utils_playzone\create_private_key.cmd
.\nordic_packaging_utils_playzone\create_public_key_c.cmd
.\nordic_packaging_utils_playzone\generate_mergehex_image.cmd
<!-- .\nordic_packaging_utils_playzone\upload_image.cmd mergedhex.hex -->
.\nordic_packaging_utils_playzone\generate_dfu_package.bat
```

## Requirements

1) `git clone --recurse-submodules https://github.com/YoraiLevi/nordic_app_dfu_playzone.git`
2) SDK v16.0.0
   * run `SDK_SYMLINK.ps1 "PathToSDK\nRF5SDK160098a08e2"`  
   the examples require the sdk to be located two folders up the git repo's folder

3) Python
   * install with [chocolatey](https://chocolatey.org/install#:~:text=now%20run%20the%20following%20command%3A) (requires admin)  
   `choco install python`
   * install from [Python.org](https://www.python.org/downloads/#:~:text=download%20python)
   * upgrade pip for installing packages from pypi(`recommended`, **not as admin**):  
   `py -m pip install --upgrade pip` -->

4) nrfutil globally (**don't** install python packages **as admin**)  
   `py -m pip install nrfutil`

5) [nRF Command Line Tools](https://www.nordicsemi.com/Products/Development-tools/nRF-Command-Line-Tools/Download#infotabs)
6) [Embedded Studio for ARM](https://www.segger.com/downloads/embedded-studio/#ESforARM)
7) [nRF connect](https://www.nordicsemi.com/Products/Development-tools/nRF-Connect-for-desktop)

## Flash Memory Layout

there is an xml file describing that. idk

## Procedures

### Using Examples

#### running app (only)

```
nrfjprog -f nrf52 --program ..\..\examples\peripheral\blinky\hex\blinky_pca10056_mbr.hex --recover --verify --reset
```

```
nrfjprog -e
nrfjprog -f nrf52 --program ..\..\components\softdevice\s140\hex\s140_nrf52_7.0.1_softdevice.hex --verify
nrfjprog -f nrf52 --program ..\..\examples\ble_peripheral\ble_app_blinky\hex\ble_app_blinky_pca10056_s140.hex --verify
nrfjprog --reset

```

* with RTT debugging enabled: `#define NRF_LOG_BACKEND_RTT_ENABLED 1`

```
nrfjprog -e
nrfjprog -f nrf52 --program ..\..\components\softdevice\s140\hex\s140_nrf52_7.0.1_softdevice.hex --verify
nrfjprog -f nrf52 --program ble_app_blinky\pca10056\s140\ses\Output\Release\Exe\ble_app_blinky_pca10056_s140.hex --verify
nrfjprog --reset

```

![](assets/memory_after_flashing_blinky.png)

<details>
<summary>logging output</summary>

```
00> <info> app_timer: RTC: initialized.
00> 
00> <info> app: Blinky example started.
00> 
```

</details>

#### running bootloader (only)

```
nrfjprog -e
nrfjprog -f nrf52 --program ..\..\examples\dfu\secure_bootloader\pca10056_s140_ble_debug\hex\secure_bootloader_ble_s140_pca10056_debug.hex --verify
nrfjprog --reset

```

<details>
<summary>logging output</summary>

```
00> <info> app: Inside main
00> 
00> <debug> app: In nrf_bootloader_init
00> 
00> <debug> nrf_dfu_settings: Calling nrf_dfu_settings_init()...
00> 
00> <debug> nrf_dfu_flash: Initializing nrf_fstorage_nvmc backend.
00> 
00> <debug> nrf_dfu_settings: Using settings page.
00> 
00> <debug> nrf_dfu_settings: Copying forbidden parts from backup page.
00> 
00> <debug> nrf_dfu_settings: Destination settings are identical to source, write not needed. Skipping.
00> 
00> <info> nrf_dfu_settings: Backing up settings page to address 0xFE000.
00> 
00> <debug> nrf_dfu_settings: Destination settings are identical to source, write not needed. Skipping.
00> 
00> <debug> app: Enter nrf_bootloader_fw_activate
00> 
00> <info> app: No firmware to activate.
00> 
00> <info> app: Boot validation failed. No valid app to boot.
00> 
00> <debug> app: DFU mode because app is not valid.
00> 
00> <info> nrf_bootloader_wdt: WDT is not enabled
00> 
00> <debug> app: in weak nrf_dfu_init_user
00> 
00> <debug> app: timer_stop (0x20005984)
00> 
00> <debug> app: timer_activate (0x20005984)
00> 
00> <info> app: Entering DFU mode.
00> 
00> <debug> app: Initializing transports (found: 1)
00> 
00> <debug> nrf_dfu_ble: Initializing BLE DFU transport
00> 
00> <debug> nrf_dfu_ble: Setting up vector table: 0x000F1000
00> 
00> <debug> nrf_dfu_ble: Enabling SoftDevice.
00> 
00> <debug> nrf_dfu_ble: Configuring BLE stack.
00> 
00> <debug> nrf_dfu_ble: Enabling the BLE stack.
00> 
00> <debug> nrf_dfu_ble: No advertising name found
00> 
00> <debug> nrf_dfu_ble: Using default advertising name
00> 
00> <debug> nrf_dfu_ble: Advertising...
00> 
00> <debug> nrf_dfu_ble: BLE DFU transport initialized.
00> 
00> <debug> nrf_dfu_flash: Initializing nrf_fstorage_sd backend.
00> 
00> <debug> app: Enter main loop
00> 

```

</details>

![](assets/memory_after_flashing_bootloader.png)

##### uploading dfu-bootloader image and performing dfu from phone

using [nRF Toolbox for Bluetooth LE](https://play.google.com/store/apps/details?id=no.nordicsemi.android.nrftoolbox&hl=en) upload `..\..\examples\dfu\secure_dfu_test_images\ble\nrf52840\hrs_application_s140.zip`

<details>
<summary>logging output</summary>

```
00> <info> app: Inside main
00>
00> <debug> app: In nrf_bootloader_init
00>
00> <debug> nrf_dfu_settings: Calling nrf_dfu_settings_init()...
00>
00> <debug> nrf_dfu_flash: Initializing nrf_fstorage_nvmc backend.
00>
00> <debug> nrf_dfu_settings: Using settings page.
00>
00> <debug> nrf_dfu_settings: Copying forbidden parts from backup page.
00>
00> <debug> nrf_dfu_settings: Destination settings are identical to source, write not needed. Skipping.
00>
00> <info> nrf_dfu_settings: Backing up settings page to address 0xFE000.
00>
00> <debug> nrf_dfu_settings: Destination settings are identical to source, write not needed. Skipping.
00>
00> <debug> app: Enter nrf_bootloader_fw_activate
00>
00> <info> app: No firmware to activate.
00>
00> <debug> app: App is valid
00>
00> <info> nrf_dfu_settings: Backing up settings page to address 0xFE000.
00>
00> <debug> nrf_dfu_settings: Destination settings are identical to source, write not needed. Skipping.
00>
00> <debug> app: Running nrf_bootloader_app_start with address: 0x00001000
00>
00> <debug> app: Disabling interrupts. NVIC->ICER[0]: 0x0
00>

```

</details>

![](assets/memory_after_dfu.png)

### Building the bootloader ourselves

##### creating private-public key pair

##### flashing new bootloader

##### creating application update image and uploading from phone

### Flashing everything at one time

#### Debugging

### Private and Public keys (`nrfutil keys`)

the `nrfutil keys` utility creates private,public keys including c implementation:

#### generating private key (`create_private_key.cmd`)

```
nrfutil keys generate private.pem
```

#### generating public key for c usage (`create_public_key_c.cmd`)

```
nrfutil keys display --key pk --format code private.pem > dfu_public_key.c
```

### Merging bootloader and an Application(+softdevice) images (`nrfutil settings`,`mergehex`)

#### [generating bootloader settings page](https://infocenter.nordicsemi.com/index.jsp?topic=%2Fug_nrfutil%2FUG%2Fnrfutil%2Fnrfutil_settings_generate_display.html)

The bootloader settings page is required on the device so that it can boot the application. Among other information, this page contains the CRC value and length of the bootable application (if present). This CRC value is calculated on boot-up to verify that a valid application is present.

```cmd
echo "## Creating bootloader settings based on app.hex"
nrfutil settings generate --family NRF52 --application app.hex --application-version 1 --bootloader-version 1 --bl-settings-version 1 settings.hex
echo.
echo "## Merging bootloader settings and app.hex into merged.hex"
mergehex -m app.hex settings.hex -o merged.hex
echo.
```

### Performing DFU

#### Generating update packages (`nrfutil pkg`)

 The following combinations are supported (12/07/2021):  
| 1 item                                          | 2 items                                              | 3 items                    |
| ----------------------------------------------- | ---------------------------------------------------- | -------------------------- |
| BL only: Supported✅.                            | BL + SD: Supported✅.                                 | BL + SD + APP: Supported✅. |
| SD only: Supported✅ (SD of same Major Version). | BL + APP: Not Supported❌ (use two packages instead). |
| APP only: Supported✅ (external or internal).    | SD + APP: Supported✅ (SD of same Major Version)      |

command prompt:

```cmd
nrfutil pkg generate ^
--key-file keys\private.pem ^
--hw-version 52 ^
--debug-mode ^
--application app\pca10056\s140\ses\Output\Release\Exe\ble_app_blinky_pca10056_s140.hex ^
--application-version-string "0.0.0" ^
--bootloader bl\pca10056_s140_ble_debug\ses\Output\Release\Exe\secure_bootloader_ble_s140_pca10056_debug.hex ^
--bootloader-version 0 ^
--softdevice softdevice\s140\hex\s140_nrf52_7.0.1_softdevice.hex ^
--sd-req 0xCA ^
--sd-id 0xCA ^
BL_SD_APP_package.zip
nrfutil pkg generate ^
--key-file keys\private.pem ^
--hw-version 52 ^
--debug-mode ^
--application app\pca10056\s140\ses\Output\Release\Exe\ble_app_blinky_pca10056_s140.hex ^
--application-version-string "0.0.0" ^
APP_package.zip
```

additional flags:

```cmd
One of : |s140_nrf52_6.0.0|0xA9|, |s140_nrf52_6.1.0|0xAE|, |s140_nrf52_6.1.1|0xB6|, |s140_nrf52_7.0.0|0xC1|, |s140_nrf52_7.0.1|0xCA|
--sd-boot-validation [NO_VALIDATION|VALIDATE_GENERATED_CRC|VALIDATE_GENERATED_SHA256|VALIDATE_ECDSA_P256_SHA256]
--app-boot-validation [NO_VALIDATION|VALIDATE_GENERATED_CRC|VALIDATE_GENERATED_SHA256|VALIDATE_ECDSA_P256_SHA256]
```

#### Uploading bootloader and flashing application through phone

1) download [nRF Toolbox for Bluetooth LE](https://play.google.com/store/apps/details?id=no.nordicsemi.android.nrftoolbox&hl=en)
2) open and press DFU
3) select the Dfu Target of your choice (DfuTarg)
4) select file
5) upload

#### Uploading bootloader and flashing application through PC

??????????????????????????????????????????????????????????  
the cli doesn't work for me atm?  
probably with nrf connect + ble dongle ??????  
jtagging  

## References

[nRF52832-buttonless-dfu-development-tutorial
](https://github.com/gamnes/nRF52832-buttonless-dfu-development-tutorial) - Seem like a nice tutorial just running `.bat` files

### Documentation regarding nordic's DFU

* [Bootloader and DFU modules](https://infocenter.nordicsemi.com/topic/sdk_nrf5_v16.0.0/lib_bootloader_modules.html)
  * [Memory Layout](https://infocenter.nordicsemi.com/index.jsp?topic=%2Fsdk_nrf5_v16.0.0%2Flib_bootloader.html&anchor=lib_bootloader_memory) - Nice table + image
  * [Generating and displaying private and public keys](https://infocenter.nordicsemi.com/index.jsp?topic=%2Fug_nrfutil%2FUG%2Fnrfutil%2Fnrfutil_keys_generate_display.html)
