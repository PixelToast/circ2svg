# circ2svg
Renders Logisim's circ format to SVG

![](https://cdn.rawgit.com/PixelToast/circ2svg/master/potato.svg)

## Requirements
  Lua 5.1 or greater<br/>
  xml ( http://doc.lubyk.org/xml.html ) `luarocks install xml`
  
## Usage
  `lua main.lua sample.circ > out.svg`

## Limitations
  Currently only supports wires and medium sized AND/OR gates
