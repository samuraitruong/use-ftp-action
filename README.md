# FTP Sync Action

An FTP client action to sync data between CI & remote FTP server.

## Usage

```yaml
name: FTP Sync

on:
  push:
    branches:
      - main # Change this to your branch name

jobs:
  ftp-sync:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v2

      - name: FTP Sync Action
        uses: samuraitruong/use-ftp-action@main
        with:
          FTP_USER: ${{ secrets.FTP_USERNAME }}
          FTP_PASSWORD: ${{ secrets.FTP_PASSWORD }}
          FTP_HOST: ${{ secrets.FTP_HOST }}
          FTP_ROOT_FOLDER: ${{ secrets.FTP_ROOT_FOLDER }}
          LOCAL_FOLDER: ${{ secrets.LOCAL_FOLDER }}
          SYNC_MODE: ${{ secrets.SYNC_MODE }}
```

## Inputs

### `FTP_USER` (required)

Username to access the FTP server.

### `FTP_PASSWORD` (required)

Password to access the FTP server.

### `FTP_HOST` (required)

FTP server name or IP address.

### `FTP_ROOT_FOLDER` (optional)

The root folder on the FTP server. Defaults to `'.'`.

### `LOCAL_FOLDER` (optional)

Local folder name. Defaults to `'.'`.

### `SYNC_MODE` (optional)

Specifies the sync mode. Valid values are `'download'` or `'upload'`. Defaults to `'download'`.

## Example

```yaml
uses: samuraitruong/use-ftp-action@main
with:
  FTP_USER: ${{ secrets.FTP_USERNAME }}
  FTP_PASSWORD: ${{ secrets.FTP_PASSWORD }}
  FTP_HOST: ${{ secrets.FTP_HOST }}
  FTP_ROOT_FOLDER: 'htdocs'
  LOCAL_FOLDER: 'www'
  SYNC_MODE: 'download'
```

This example syncs the `htdocs` folder on the FTP server with the `www` folder locally using the specified FTP credentials.
