
```
- enable (en)
- configure terminal (conf t)
- hostname <nommachine>
- ipv6 unicast-routing
- interface gigabitEthernet <°/°>
- description <Description de l'interface>
- ip address <adresseIP> <netmask>
- ipv6 enable
- ipv6 address <adresseIPv6/préfixe>
- no shutdown
- exit
- end
- do write
- write memory
- ip route <adresseréseau> <netmask> <adresseIPinterfacerouteur>
- ipv6 route <adresseréseauIPv6/préfixe> <adresseIPv6interfacerouteur>
- show ip route
- show ipv6 route
```