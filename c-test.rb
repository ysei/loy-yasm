require 'yasm'
iseq = YASM.toplevel([]){
putnil
putobject 10
putobject 20
send :*, 1
putobject 30
send :+, 1
putobject 40
send :+, 1
call :puts, 1
leave
}
 iseq.eval
