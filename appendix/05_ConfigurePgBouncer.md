# Configure PgBouncer

## Create SSL Certs

- Perform the activities in the [Configure Postgres SSL](./04_ConfigurePostgresSSL.md).

## Install PgBouncer

It is easiest to utilize the StackBuilder version that comes with the PostgreSQL download to run PgBouncer or it can be manually downloaded. However, getting PgBouncer to compile on Windows is quite the chore.  The StackBuilder install comes with all the pre-compiled dlls and libraries that is needed whereas the manual download of PgBouncer will require many extra steps.

### Enterprise Database StackBuilder Install

- After running the [Setup](./00_Setup.md) steps, StackBuilder should have downloaded PgBouncer already.

- After setting up SSL, run the `edb_pgbouncer.exe` installer
- Click through all dialogs
- Open a command prompt, start pgbouncer as a windows service:

```cmd
cd c:\program files (x86)\pgbouncer\bin

pgbouncer -regservice "c:\program files (x86)\pgbouncer\share\pgbouncer.ini"

net start pgbouncer
```

### Fresh Download of PgBounder (Optional)

This path assumed the installer is not available and PgBouncer must be compiled from source code. It can be skipped if the above steps were completed.

- Open the [pgbounder github](https://github.com/pgbouncer/pgbouncer/releases)
- Download the latest windows i686.zip
- Unzip the file to `c:\program files (x86)\pgbouncer`

#### Download libevent

- Open the [libevent github](https://github.com/libevent/libevent/releases)
- Download the latest release
- Unzip to `c:\program files (x86)\libevent`
- Compile the libevent dlls
- Copy the libevent dlls to the `c:\program files (x86)\pgbouncer` directory

#### Configure Windows Server

- Open the `C:\OpenSSL-Win64` directory, copy the following files to the `c:\program files (x86)\pgbouncer` directory
- Remove the `x64` from the file names

#### Start PgBouncer

- Open a command prompt as administrator
- Run the following commands:

```cmd
cd c:\program files (x86)\pgbouncer

pgbouncer -regservice pgbouncer.ini

regsvr32 pgbevent.dll

net start pgbouncer

```

## Configure pgbouncer.ini file

- After installing PgBouncer from one of the above paths, open the `c:\program files (x86)\pgbouncer\share\pgbouncer.ini` file
- Add the following under the `[databases]` section

```text
reg_app = dbname=reg_app host=localhost port=5432
```

- Scroll down to the TLS settings, modify the following values

```text
;; disable, allow, require, verify-ca, verify-full
client_tls_sslmode = allow

;; Path to file that contains trusted CA certs
client_tls_ca_file = C:\Program Files (x86)\PgBouncer\share\root.crt

;; Private key and cert to present to clients.
;; Required for accepting TLS connections from clients.
client_tls_key_file = C:\Program Files (x86)\PgBouncer\share\server.key
client_tls_cert_file = C:\Program Files (x86)\PgBouncer\share\server.crt

;; fast, normal, secure, legacy, <ciphersuite string>
client_tls_ciphers = normal
```

- Copy the certificates created in the SSL steps above to the `c:\program files (x86)\PgBouncer\share` folder
- Copy the server.crt and rename the copy to `root.crt`
- Restart the PgBouncer Service

```cmd
net stop pgbouncer
net start pgbouncer
```

## Test PgBouncer

- With PgBouncer running, switch to pgAdmin
- Right-click the **Servers** node
- Select **Create->Server**
- For the name, type **pgbouncer-localhost**
- Select the **Connection** tab
- For the host name, type **localhost**
- For the port, type **6432**
- Type the password for the **postgres** user
- Click **Save**
- Expand the Databases node, the reg_app database should be displayed