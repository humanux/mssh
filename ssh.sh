#!/bin/bash
auto_smart_ssh () {
    expect -c "set timeout -1;
                spawn ssh -o StrictHostKeyChecking=no $2 ${@:3};
                expect {
                    *assword:* {send -- $1\r;
                                 expect { 
                                    *denied* {exit 2;}
                                    eof
                                 }
                    }
                    eof         {exit 1;}
                }
                " 
    return $?
}
auto_smart_ssh $1 root@$2 ${@:3}
echo -e "\n---Exit Status: $?"
