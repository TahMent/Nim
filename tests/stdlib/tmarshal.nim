discard """
  output: '''{"age": 12, "bio": "Я Cletus", "blob": [65, 66, 67, 128], "name": "Cletus"}
true
true
alpha 100
omega 200
Some(null)
None[JsonNode]
(numeric: "")
hello world
'''
joinable: false
"""

#[
joinable: false pending https://github.com/nim-lang/Nim/issues/9754
]#

import marshal

template testit(x) = discard $$to[typeof(x)]($$x)

var x: array[0..4, array[0..4, string]] = [
  ["test", "1", "2", "3", "4"], ["test", "1", "2", "3", "4"],
  ["test", "1", "2", "3", "4"], ["test", "1", "2", "3", "4"],
  ["test", "1", "2", "3", "4"]]
testit(x)
var test2: tuple[name: string, s: int] = ("tuple test", 56)
testit(test2)

type
  TE = enum
    blah, blah2

  TestObj = object
    test, asd: int
    case test2: TE
    of blah:
      help: string
    else:
      discard

  PNode = ref TNode
  TNode = object
    next, prev: PNode
    data: string

proc buildList(): PNode =
  new(result)
  new(result.next)
  new(result.prev)
  result.data = "middle"
  result.next.data = "next"
  result.prev.data = "prev"
  result.next.next = result.prev
  result.next.prev = result
  result.prev.next = result
  result.prev.prev = result.next

var test3: TestObj
test3.test = 42
test3.test2 = blah
testit(test3)

var test4: ref tuple[a, b: string]
new(test4)
test4.a = "ref string test: A"
test4.b = "ref string test: B"
testit(test4)

var test5 = @[(0,1),(2,3),(4,5)]
testit(test5)

var test7 = buildList()
testit(test7)

var test6: set[char] = {'A'..'Z', '_'}
testit(test6)


# bug #1352

type
  Entity = object of RootObj
    name: string

  Person = object of Entity
    age: int
    bio: string
    blob: string

var instance1 = Person(name: "Cletus", age: 12,
                       bio: "Я Cletus",
                       blob: "ABC\x80")
echo($$instance1)
echo(to[Person]($$instance1).bio == instance1.bio) # true
echo(to[Person]($$instance1).blob == instance1.blob) # true

# bug 5757

type
  Something = object
    x: string
    y: int

var data1 = """{"x": "alpha", "y": 100}"""
var data2 = """{"x": "omega", "y": 200}"""

var r = to[Something](data1)

echo r.x, " ", r.y

r = to[Something](data2)

echo r.x, " ", r.y


type
  Foo = object
    a1: string
    a2: string
    a3: seq[string]
    a4: seq[int]
    a5: seq[int]
    a6: seq[int]
var foo = Foo(a2: "", a4: @[], a6: @[1])
foo.a6.setLen 0
doAssert $$foo == """{"a1": "", "a2": "", "a3": [], "a4": [], "a5": [], "a6": []}"""
testit(foo)

import options, json

# bug #15934
block:
  let
    a1 = some(newJNull())
    a2 = none(JsonNode)
  echo ($$a1).to[:Option[JsonNode]]
  echo ($$a2).to[:Option[JsonNode]]


# bug #15620
block:
  let str = """{"numeric": null}"""

  type
    LegacyEntry = object
      numeric: string

  let test = to[LegacyEntry](str)
  echo test

# bug #16022
block:
  let p: proc () = proc () = echo "hello world"
  let poc = (to[typeof(p)]($$p))
  poc()
