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
  "network": {
    "connections": [
      {
        "id": "Wired connection 1",
        "interface": ethernet,
        "method4": "auto"
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
            "search": "*",
            "delete": true
          },
          {
            "filesystem": {
              "type": "ext4",
              "path": "/",
              "mountBy": "uuid",
              "mountOptions": [
                "defaults",
                "noatime"
              ]
            },
            "size": "10 GiB"
          },
          {
            "encryption": {
              "luks2": {
                "password": "nots3cr3t",
                "pbkdFunction": "pbkdf2"
              }
            },
            "filesystem": {
              "type": "ext4",
              "path": "/home",
              "mountBy": "uuid",
              "mountOptions": [
                "defaults",
                "noatime"
              ]
            }
          },
          {
            "encryption": "random_swap",
            "filesystem": {
              "type": "swap",
              "path": "swap"
            },
            "size": "2 GiB"
          }
        ]
      }
    ]
  },
  "software": {
    "patterns": [
      "gnome"
    ]
  }
}

