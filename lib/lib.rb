require("lib/read.rb")
require("lib/loy.rb")
def string?(a)
a.kind_of?(String)
end
def number?(o)
o.kind_of?(Numeric)
end
def symbol?(o)
o.kind_of?(Symbol)
end
def eq?(a, b)
a.equal?(b)
end
def null?(a)
a.nil?()
end
S_READER = Reader.new()
def read(io)
S_READER(io)
end
def open_input_file(path)
open(path,"r")
end
def map(fn, lis)
if null?(lis)
nil
else
[fn.call(lis[0]),map(fn,lis[1])]
end
end