# zabbix-sshkeys

This user parameter will parsed the `/var/log/auth.log` file for successful logins with a publickey and send results per key with the time of this login to a zabbix server trapper item.

The parser gets triggered by another Zabbix Agent Item which sends a request and forks Zabbix Sender in his answer.

As a result you will get an item with a login history of ssh pubkeys and one item per ssh session which helds the used pubkey or "closed" if already closed.

## Prequsites

- `zabbix-agent2` needs to be installed (assumed in `/etc/zabbix`)
  - Refer to the [Zabbix Docs](https://www.zabbix.com/download)
- `zabbix_sender` needs to be installed
  - `apt install zabbix-sender`
- User `zabbix` can read `/var/log/auth.log`
  - ...either `setfacl -m u:zabbix:r /var/log/auth.log`
  - ...or `usermod -a -G adm zabbix`
- The `zabbix_agent2.conf` need to have all values necessary to connect to the Zabbix server, especially:
  - Key: `Hostname`
    - Must match with the Host the values refer to in Zabbix. *Visible Name* **will not** work here!
  - Key: `ServerActive`
    - (will be used for the destination; you may want to specify a custom port here)

## Setup

Assuming your are in the folder of the cloned Repo and your agent is in `/etc/zabbix`:

```sh
# Create scripts folder if not exists and change permission
mkdir /etc/zabbix/scripts > /dev/null 2>&1
chown zabbix: /etc/zabbix/scripts

# Copy script and change permission
cp *.sh /etc/zabbix/scripts/
chown zabbix: /etc/zabbix/scripts/ssh-login-*.sh
chmod ug+x /etc/zabbix/scripts/ssh-login-*.sh

# Copy the config and populate the new parameter in it
cp ssh-logins.conf /etc/zabbix/zabbix_agent2.d/ssh-logins.conf
systemctl restart zabbix-agent2
```

You can adjust the path of your agent config and the logfile you want to look at optionally.

You can now import the `ssh-logins.yaml` as a new template in your Zabbix frontend and assign it to any of your Linux hosts.

### Map known Keys to persons/names

Edit the *Value Mapping* either in the YAML before import or in the Zabbix Template entry to match the value of a key with a name. Both will then show up in the value history for readablity but leaving the raw data unchanged.
