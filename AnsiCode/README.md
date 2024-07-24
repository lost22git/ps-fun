
## Functions


### Show-AnsiCode


```powershell
Show-AnsiCode
```

![Show-AnsiCode](https://github.com/lost22git/AnsiCode/assets/65008815/9cc3a8a0-db16-4fd3-9016-f2148f0eadf4)


### Add-AnsiStyle


```powershell
$a = "hello" | Add-AnsiStyle -Style underline | Add-AnsiStyle -Style reset | Add-AnsiStyle -Style bold,bgBlue
$b = "world" | Add-AnsiStyle -Style underline | Add-AnsiStyle -Style bgRed,italic
$a.ToRawString()
"$a"
$b.ToRawString()
"$b"

$c = $a.AddText($b)
$c.ToRawString()
"$c"

$d = $c | Add-AnsiStyle -Style strike
$d.ToRawString()
"$d"

$e = "$d" | Add-AnsiStyle -Style notStrike,invert
$e.ToRawString()
"$e"
```

![Add-AnsiStyle](https://github.com/lost22git/AnsiCode/assets/65008815/72e0cafa-eea3-40e7-b5d7-7dcbc4afcebf)

