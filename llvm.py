#!/usr/bin/env python3
# stdin: flagpole code
# stdout: fasm code
import sys
import re
import os

def setup_code():
  with open("/usr/lib/flagpole/setup.ll") as f:
    print(f.read())

def end_code():
  with open("/usr/lib/flagpole/end.ll") as f:
    print(f.read())

def get_str_len(s):
  raw_len = len(s)
  hex_escapes = len(re.findall(r'\\[0-9a-fA-F]{2}', s))
  normal_escapes = len(re.findall(r'\\\\', s))
  return raw_len - 2*hex_escapes - normal_escapes

def load_library_text(filename):
    search_paths = [
        ".",
        "/usr/lib/flagpole",
    ]

    for directory in search_paths:
        full_path = os.path.join(directory, filename)

        if os.path.isfile(full_path):
            try:
                with open(full_path, "r", encoding="utf-8") as f:
                    return f.read()
            except OSError:
                print(
                    f"Readerror: '{filename}'",
                    file=sys.stderr
                )
                exit(1)

    print(
        f"Error: '{filename}' not found", file=sys.stderr
    )
    exit(1)

setup_code()
code = sys.stdin.read()
macros = ""
for line in code.split("\n"):
  if len(line) == 0:
    continue
  if line[0] != "$":
    break
  tokens = line.split()
  if tokens[0] == "$inc":
    macros += load_library_text(tokens[1])

code += macros
externs = []
for line in code.split("\n"):
  tokens = line.split()
  if len(tokens) == 0:
    continue
  if tokens[0] == "$extern":
    externs.append((tokens[1], tokens[2:]))

code += "\n"
decommented_lines = []
for line in code.splitlines():
    if line.lstrip().startswith("#"):
        continue
    decommented_lines.append(line)
code = "\n".join(decommented_lines)

tokens = []
isQuote = False
acc = ""
for c in code:
  #print(f"processing {c}: {ord(c)}",file=sys.stderr)
  if c.isspace() and not isQuote:
    if acc.isnumeric():
      tokens.append((0,acc))
    else:
      tokens.append((1,acc))
    acc = ""
    continue
  if c == '"':
    if isQuote:
      tokens.append((2,acc))
      isQuote = False
    else:
      if acc != "":
        print("String next to other type, failing!", file=sys.stderr)
        exit(1)
      isQuote = True
    continue
  acc += c
      

for extern in externs:
  argslist = ""
  for i in range(1,len(extern)):
    if extern[i] == "i":
      argslist += "i64"
    if extern[i] == "d":
      argslist += "f64"
    if extern[i] == "f":
      argslist += "f32"
    if i != len(extern) - 1:
      argslist += ","
  print(f"declare i64 @{extern[0]}({argslist})")

labelstack = []
labelmax = 0

i = 0
while i < len(tokens):
  token = tokens[i]
  if token[0] == 0:
    if "." in token[1]:
      print(f"\tcall void @__fp_internal_push(i64 {struct.pack('<d',float(token[1])).hex()})")
    else:
      print(f"\tcall void @__fp_internal_push(i64 {int(token[1])})")
  if token[0] == 1 and token[1] == "proc":
    i += 1
    name = tokens[i][1]
    print(f"define void @__fp_user_{name}() {{")
    print(f"entry:")
  if token[0] == 2:
    # print(f"token: {token}", file=sys.stderr)
    contents = token[1]

    l = get_str_len(contents)+1
    print(f"\t%buf{i} = alloca [{l} x i8]")
    print(f"\tstore [{l} x i8] c\"{contents}\\00\", [{l} x i8]* %buf{i}")
    print(f"\t%realbuf{i} = getelementptr [{l} x i8], [{l} x i8]* %buf{i}, i32 0, i32 0")
    print(f"\t%ptr{i} = ptrtoint i8* %realbuf{i} to i64")
    print(f"\tcall void @__fp_internal_push(i64 %ptr{i})")
  if token[0] == 1 and token[1].startswith(":"):
    procname = token[1][1:]
    extmatch = next((t for t in externs if t[0] == procname), None)
    if extmatch:
      args = extmatch[1]
      arglist = ""
      for k,arg in enumerate(args):
        if arg == "f":
          arglist += "f32 "
        if arg == "d":
          arglist += "f64 "
        if arg == "i":
          arglist += "i64 "
        arglist += f"%arg{i}_{k}"
        if k != len(args)-1:
          arglist += ","
      for k,arg in enumerate(args):
        print(f"\t%arg{i}_{k}_i = call i64 @__fp_internal_pop()")
        if arg == "i":
          print(f"\t%arg{i}_{k} = add i64 %arg{i}_{k}_i, 0")
        if arg == "f":
          print(f"\t%arg{i}_{k} = bitcast i64 %arg{i}_{k}_i to f32")
        if arg == "d":
          print(f"\t%arg{i}_{k} = bitcast i64 %arg{i}_{k}_i to f64")
      print(f"\t%r_{i} = call i64 @{procname}({arglist})")
      print(f"\tcall void @__fp_internal_push(i64 %r_{i})")
    else:
      print(f"\tcall void @__fp_user_{procname}()")
  if token[0] == 1 and token[1] == "endproc":
    print(f"\tret void")
    print(f"}}")
  if token[0] == 1 and token[1] == "return":
    print(f"\tret void")
  if token[0] == 1 and token[1] == "i+":
    print(f"\tcall void @__fp_internal_addints()")
  if token[0] == 1 and token[1] == "i-":
    print(f"\tcall void @__fp_internal_subints()")
  if token[0] == 1 and token[1] == "i*":
    print(f"\tcall void @__fp_internal_mulints()")
  if token[0] == 1 and token[1] == "i/":
    print(f"\tcall void @__fp_internal_divints()")
  if token[0] == 1 and token[1] == "not":
    print(f"\tcall void @__fp_internal_not()")
  if token[0] == 1 and token[1] == "~":
    print(f"\tcall void @__fp_internal_bitnot()")
  if token[0] == 1 and token[1] == "==":
    print(f"\tcall void @__fp_internal_equals()")
  if token[0] == 1 and token[1] == "i>":
    print(f"\tcall void @__fp_internal_igt()")
  if token[0] == 1 and token[1] == "i<":
    print(f"\tcall void @__fp_internal_ilt()")
  if token[0] == 1 and token[1] == "dup":
    print(f"\tcall void @__fp_internal_duplicate()")
  if token[0] == 1 and token[1] == "swap":
    print(f"\tcall void @__fp_internal_swap()")
  if token[0] == 1 and token[1] == "drop":
    print(f"\t%dummy{i} = call i64 @__fp_internal_pop()")
  if token[0] == 1 and token[1] == "pick":
    print(f"\tcall void @__fp_internal_pick()")
  if token[0] == 1 and token[1] == "poke":
    print(f"\tcall void @__fp_internal_poke()")
  if token[0] == 1 and token[1] == "if":
    labelstack.append(labelmax)
    labelmax += 1
    # no code generation actually, very cool
  if token[0] == 1 and token[1] == "then":
    print(f"\t%v{i} = call i64 @__fp_internal_pop()")
    print(f"\t%c{i} = trunc i64 %v{i} to i1")
    print(f"\tbr i1 %c{i}, label %head_{labelstack[-1]}, label %tail_{labelstack[-1]}")
    print(f"\nhead_{labelstack[-1]}:")
  if token[0] == 1 and token[1] == "while":
    labelstack.append(labelmax)
    labelmax += 1
    print(f"\tbr label %head_{labelstack[-1]}")
    print(f"\nhead_{labelstack[-1]}:")
  if token[0] == 1 and token[1] == "do":
    print(f"\t%v{i} = call i64 @__fp_internal_pop()")
    print(f"\t%c{i} = trunc i64 %v{i} to i1")
    print(f"\tbr i1 %c{i}, label %mid_{labelstack[-1]}, label %tail_{labelstack[-1]}")
    print(f"\nmid_{labelstack[-1]}:")
  if token[0] == 1 and token[1] == "endwhile":
    print(f"\tbr label %head_{labelstack[-1]}")
    print(f"\ntail_{labelstack.pop()}:")
  if token[0] == 1 and token[1] == "endif":
    print(f"\tbr label %tail_{labelstack[-1]}")
    print(f"\ntail_{labelstack.pop()}:")
  if token[0] == 1 and token[1] == "ld8":
    print(f"\t%addr{i} = call i64 @__fp_internal_pop()")
    print(f"\t%ptr{i} = inttoptr i64 %addr{i} to i8*")
    print(f"\t%val{i} = load i8, i8* %ptr{i}")
    print(f"\t%x{i} = zext i8 %val{i} to i64")
    print(f"\tcall void @__fp_internal_push(i64 %x{i})")
  if token[0] == 1 and token[1] == "ld16":
    print(f"\t%addr{i} = call i64 @__fp_internal_pop()")
    print(f"\t%ptr{i} = inttoptr i64 %addr{i} to i16*")
    print(f"\t%val{i} = load i16, i16* %ptr{i}")
    print(f"\t%x{i} = zext i16 %val{i} to i64")
    print(f"\tcall void @__fp_internal_push(i64 %x{i})")
  if token[0] == 1 and token[1] == "ld32":
    print(f"\t%addr{i} = call i64 @__fp_internal_pop()")
    print(f"\t%ptr{i} = inttoptr i64 %addr{i} to i32*")
    print(f"\t%val{i} = load i32, i32* %ptr{i}")
    print(f"\t%x{i} = zext i32 %val{i} to i64")
    print(f"\tcall void @__fp_internal_push(i64 %x{i})")
  if token[0] == 1 and token[1] == "ld64":
    print(f"\t%addr{i} = call i64 @__fp_internal_pop()")
    print(f"\t%ptr{i} = inttoptr i64 %addr{i} to i64*")
    print(f"\t%val{i} = load i64, i64* %ptr{i}")
    print(f"\tcall void @__fp_internal_push(i64 %val{i})")
  if token[0] == 1 and token[1] == "st8":
    print(f"%addr{i} = call i64 @__fp_internal_pop()")
    print(f"%val{i} = call i64 @__fp_internal_pop()")
    print(f"%val8_{i} = trunc i64 %val{i} to i8")
    print(f"%ptr{i} = inttoptr i64 %addr{i} to i8*")
    print(f"store i8 %val8_{i}, i8* %ptr{i}")
  if token[0] == 1 and token[1] == "st16":
    print(f"%addr{i} = call i64 @__fp_internal_pop()")
    print(f"%val{i} = call i64 @__fp_internal_pop()")
    print(f"%val16_{i} = trunc i64 %val{i} to i16")
    print(f"%ptr{i} = inttoptr i64 %addr{i} to i16*")
    print(f"store i16 %val16_{i}, i16* %ptr{i}")
  if token[0] == 1 and token[1] == "st32":
    print(f"%addr{i} = call i64 @__fp_internal_pop()")
    print(f"%val{i} = call i64 @__fp_internal_pop()")
    print(f"%val32_{i} = trunc i64 %val{i} to i32")
    print(f"%ptr{i} = inttoptr i64 %addr{i} to i32*")
    print(f"store i32 %val16_{i}, i16* %ptr{i}")
  if token[0] == 1 and token[1] == "st64":
    print(f"%addr{i} = call i64 @__fp_internal_pop()")
    print(f"%val{i} = call i64 @__fp_internal_pop()")
    print(f"%val64_{i} = trunc i64 %val{i} to i64")
    print(f"%ptr{i} = inttoptr i64 %addr{i} to i64*")
    print(f"store i64 %val16_{i}, i16* %ptr{i}")
  i += 1

end_code()
