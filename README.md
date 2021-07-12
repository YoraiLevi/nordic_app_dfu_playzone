# nordic_app_dfu_playzone
- [nordic_app_dfu_playzone](#nordic_app_dfu_playzone)
  - [Summary](#summary)
  - [Requirements](#requirements)
  - [Flash Memory Layout](#flash-memory-layout)
  - [Procedures](#procedures)
    - [Private and Public keys (`nrfutil keys`)](#private-and-public-keys-nrfutil-keys)
      - [generating private key (`create_private_key.cmd`)](#generating-private-key-create_private_keycmd)
      - [generating public key for c usage (`create_public_key_c.cmd`)](#generating-public-key-for-c-usage-create_public_key_ccmd)
    - [Merging bootloader and an Application(+softdevice) images (`nrfutil settings`,`mergehex`)](#merging-bootloader-and-an-applicationsoftdevice-images-nrfutil-settingsmergehex)
    - [Performing DFU](#performing-dfu)
      - [Generating update packages (`nrfutil pkg`)](#generating-update-packages-nrfutil-pkg)
      - [Uploading bootloader and flashing application through phone](#uploading-bootloader-and-flashing-application-through-phone)
      - [Uploading bootloader and flashing application through PC](#uploading-bootloader-and-flashing-application-through-pc)
  - [References](#references)
    - [Documentation regarding nordic's DFU](#documentation-regarding-nordics-dfu)


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
.\nordic_packaging_utils_playzone\upload_image.cmd mergedhex.hex
.\nordic_packaging_utils_playzone\generate_dfu_package.bat
```

## Requirements

1) `git clone --recurse-submodules https://github.com/YoraiLevi/nordic_app_dfu_playzone.git`
2) SDK v16.0.0
   * run `SDK_SYMLINK.ps1`  
   the examples require the sdk to be located two folders up the git repo's folder
3) Python 3.7.9 (as of 12/07/2021 3.9,3.10 do not work, untested on later versions of 3.7.*)
   * install with [chocolatey](https://chocolatey.org/install#:~:text=now%20run%20the%20following%20command%3A) (requires admin)  
   `choco install python --version 3.7.9`
   * install from python.org  
    [Python 3.7.9](https://www.python.org/downloads/release/python-379/#:~:text=Changelog-,files,-Version)
   * upgrade pip for installing packages from pypi(`recommended`, **not as admin**):  
   `py -3.7 -m pip install --upgrade pip`
4) nrfutil globally on python 3.7.X (**don't** install python packages **as admin**)  
   `py -3.7 -m pip install nrfutil`
5) ~~[nRF Command Line Tools](https://www.nordicsemi.com/Products/Development-tools/nRF-Command-Line-Tools/Download#infotabs)~~
    * ~~I don't remember but I think I had encountered an issue that forced me to reinstall this~~
    * nrfjprog errors out always:

      ```cmd
      ERROR: The --family option given with the command (or the default from nrfjprog.ini)  
      ERROR: does not match the device connected.
      ```

6) J-Link + Segger embedded studio
   * no clue atm
7) nRF connect
   * basically gui to upload and manage stuff meanwhile i have no clue how to upload through jlink manually

## Flash Memory Layout

there is an xml file describing that. idk

## Procedures

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
|1 item|2 items|3 items|
|--|--|--|
BL only: Supported✅.|BL + SD: Supported✅.|BL + SD + APP: Supported✅.
SD only: Supported✅ (SD of same Major Version).|BL + APP: Not Supported❌ (use two packages instead).
APP only: Supported✅ (external or internal).|SD + APP: Supported✅ (SD of same Major Version)

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
