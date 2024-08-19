package crowplexus.hscript;

typedef ByteInt = #if cpp cpp.Int8 #elseif cs cs.Int8 #elseif java java.Int8 #else Int #end;
typedef ShortInt = #if cpp cpp.Int16 #elseif cs cs.Int16 #elseif java java.Int16 #else Int #end;
typedef ByteUInt = #if cpp cpp.UInt8 #elseif cs cs.UInt8 #else Int #end;
typedef ShortUInt = #if cpp cpp.UInt16 #elseif cs cs.UInt16 #else Int #end;
