# LIKO-12-API

## Spec:

### API Functions:

**Note:** The function name is determined from the file name.

#### Single usage

```json
{
  "desc":"Function desction, starts with big letter, and ends with a .\n\nLonger description",
  "note":"A note, optional, shouldn't be used when 'notes' is used",
  "notes":[
    "Accepts multiple notes.",
    "Note #2."
  ],
  "args":[
    {
      "name":"Arg 1 name",
      "type":"number",
      "desc":"Number, string, boolean, nil, any [CHOOSE ONE]"
    },
    {
      "name":"...",
      "type":["number","nil"],
      "desc":"Vararg"
    },
    {
      "name":"Optional arg",
      "type":["number","nil"],
      "default":"0",
      "desc":"Optional arg description."
    }
  ],
  "rets":[
    {
      "name":"Ret 1.",
      "type":"",
      "desc":""
    }
  ]
}
```

#### Multi usage

```json
{
  "desc":"Overall description.",
  "Usage":[
    {
      "name":"First usage:",
      "desc":"It may have a description",
      "args":[],
      "rets":[]
    },
    {
      "name":"Second usage:",
      "desc":"It may have a description",
      "args":[],
      "rets":[]
    }
  ]
}
```

**Note:** `args` and `rets` can be null.

## Event function:

**Note:** The function name is determined from the file name.

```json
{
  "desc":"desc",
  "note":"",
  "notes":["",""],
  "args":[
    {
      "name":"",
      "type":"",
      "desc":""
    }
  ]
}
```
