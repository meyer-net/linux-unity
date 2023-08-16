# linux-unity

This is a softs setup script on linux，it builds a basic environments for vms or clouds。
This projects based docker & sealos，the setup sequence is sealos > docker > compline。

You shold run it by：
` bash linux-unity/unity_installstart.sh `

The environment for dev：

```
    1：bash unity_installstart.sh
    2：when u first boot the script，Type 1 choose 'update_libs'，to adapt this script
    3: Type 2 to 'from_clean' to choose soft type which u want to setup
    3：To root menu，type 8 to 'database' then type any num which u want to setup，like mysql、postgresql
    4：To root menu，type 6 to 'bi' then type any num which u want to setup，like redis
    5：To root menu，type 9 to 'web' then type any num which u want to setup，like nginx
```

ubuntu not implements

## TODO：

1. support default security kv manager by vault of docker：like [https://zhuanlan.zhihu.com/p/608687965](url)