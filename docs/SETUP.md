# INSTALLATION

For stable versions, use this

```
haxelib install hscript-iris
```

For unstable versions however, use this

```
haxelib git hscript-iris https://github.com/crowplexus/hscript-iris/
```

Once this is done, go to your Project File, whether that be a build.hxml for Haxe Projects, or Project.xml for OpenFL and Flixel projects, and add `hscript-iris` to your libraries

---

# SETUP IN HAXE PROJECTS

### Haxe Project Example
```hxml
--library hscript-iris
# this is optional and can be added if wanted
# provides descriptive traces and better error handling at runtime
-D hscriptPos
```

### OpenFL / Flixel Project Example

```xml
<haxelib name="hscript-iris"/>
<haxedef name="hscriptPos"/>
```