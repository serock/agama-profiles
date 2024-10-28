local agama = import "hw.libsonnet";

local ethernet = std.filter(function(n) n.description == "Ethernet interface", agama.selectByClass(agama.lshw, "network"))[0].logicalname;
local drive = std.sort(
  std.filter(
    function(d) std.objectHas(d, "size"),
    agama.selectByClass(agama.lshw, "disk")),
  function(x) -x.size)[0].logicalname;

{
  "product": {
    "id": "Leap_16.0"
  },
  "localization": {
    "language": "en_US.UTF-8",
    "keyboard": "us",
    "timezone": "America/New_York"
  },
  "user": {
    "fullName": "",
    "userName": "",
    "password": ""
  },
  "root": {
    "password": ""
  },
  "network": {
    "connections": [
      {
        "id": "Wired connection 1",
        "interface": ethernet,
        "method4": "auto",
        "method6": "disabled",
        "ignore_auto_dns": false
      }
    ]
  },
  "storage": {
    "boot": {
      "configure": true,
      "device": drive
    },
    "drives": [
      {
        "search": drive,
        "ptableType": "gpt",
        "partitions": [
          {
            "delete": true,
            "search": {
              "ifNotFound": "skip"
            }
          },
          {
            "id": "linux",
            "size": "100 GiB",
            "filesystem": {
              "type": "ext4",
              "path": "/",
              "mountBy": "uuid",
              "mountOptions": [
                "noatime",
                "acl",
                "user_xattr"
              ]
            }
          },
          {
            "id": "linux",
            "encryption": {
              "luks2": {
                "password": "",
                "pbkdFunction": "pbkdf2",
                "label": "crypt_home"
              }
            },
            "filesystem": {
              "type": "ext4",
              "path": "/home",
              "mountBy": "uuid",
              "mountOptions": [
                "noatime",
                "acl",
                "user_xattr"
              ]
            }
          },
          {
            "id": "swap",
            "size": "2 GiB",
            "filesystem": {
              "type": "swap",
              "path": "none",
              "mountBy": "uuid"
            }
          }
        ]
      }
    ]
  },
  "software": {
    "patterns": [
      "yast2_basis",
      "yast2_desktop",
      "gnome"
    ]
  }
}

