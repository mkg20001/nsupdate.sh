# nsupdate.sh

Simple nsupdate.info daemon service script

## Usage

First create a config in the following format:
```sh
nsupdate your-sub-domain.nsupdate.info YOURPASSWORD
```

Then to run the script once:
```sh
CONFIG=/path/to/your/config.sh bash nsupdate.sh
```

Or run it with a periodic update parameter
```sh
LOOP=2h CONFIG=/path/to/your/config.sh bash nsupdate.sh
```

You can also install it using `make install` or install the service with `make install-service`
