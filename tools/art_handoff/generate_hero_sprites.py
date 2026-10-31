from PIL import Image, ImageDraw
import math, json, os, zipfile
out='/mnt/data/RUNEBOUND_Hero_Sprite_Pack_v1'; path=out+'/assets/characters/hero'; os.makedirs(path,exist_ok=True)
P={'hair':'#e9be62','hairshade':'#b78339','skin':'#f4c7a1','skinshadow':'#c68869','tunic':'#367ea8','tunicshade':'#24506b','cape':'#d44a4f','capeshade':'#8d2635','leather':'#6b4e36','boot':'#4a3624','wood':'#8b6f46','steel':'#c8d0d8','shadow':'#1e2d39','glow':'#44d2ff','trim':'#a4b56a','white':'#f2e7d8'}
def frame(kind,i,n):
 im=Image.new('RGBA',(32,48)); d=ImageDraw.Draw(im)
 wave=math.sin(i*2*math.pi/max(n,1)); bob=round(1*wave) if kind in ('idle','run') else 0
 if kind=='run': bob=round(abs(wave)*2)
 if kind=='jump': bob=-1
 if kind=='double_jump': bob=-2
 if kind=='fall':bob=1
 if kind=='hurt':bob=-1
 if kind=='death':bob=7 if i>1 else 0
 if kind=='land':bob=2 if i==0 else 0
 # consistent foot baseline at 46 except deliberate airborne pose
 y=lambda z:z+bob
 # cape behind torso, animation trails left
 cape_len=8+(2 if kind in ('run','jump','double_jump') else 0)
 cape_shift=round(2*wave) if kind in ('run','idle') else -2
 d.polygon([(11,y(18)),(15,y(19)),(10+cape_shift,y(29)),(9-cape_len//2,y(36)),(7-cape_len//2,y(31)),(8,y(23))],fill=P['capeshade'])
 d.polygon([(11,y(19)),(15,y(20)),(9+cape_shift,y(32)),(9-cape_len//2,y(34)),(9,y(25))],fill=P['cape'])
 # legs with run poses
 swing=round(4*wave) if kind=='run' else 0
 if kind in ('jump','double_jump'): swing=3
 if kind=='fall': swing=-2
 if kind=='attack':swing=2
 for x1,shift in [(13,swing),(20,-swing)]:
  xx=x1+shift//2
  d.rectangle((xx,y(33),xx+4,y(41)),fill=P['leather'])
  d.rectangle((xx-1,y(40),xx+5,y(45)),fill=P['boot'])
  d.rectangle((xx-1,y(43),xx+6,y(46)),fill=P['shadow'])
  d.rectangle((xx,y(41),xx+5,y(44)),fill=P['boot'])
 # torso
 d.polygon([(12,y(19)),(23,y(19)),(25,y(34)),(11,y(34))],fill=P['tunicshade'])
 d.polygon([(13,y(20)),(22,y(20)),(23,y(31)),(13,y(32))],fill=P['tunic'])
 d.line([(12,y(30)),(24,y(30))],fill=P['trim'],width=1)
 d.line([(14,y(23)),(22,y(28))],fill=P['leather'],width=2)
 d.rectangle((12,y(31),24,y(33)),fill=P['leather'])
 d.rectangle((18,y(31),20,y(33)),fill=P['steel'])
 # left arm
 d.rectangle((10,y(22),13,y(29)),fill=P['skinshadow']);d.rectangle((10,y(26),14,y(30)),fill=P['leather'])
 # head, hair
 d.rectangle((15,y(10),23,y(20)),fill=P['skinshadow'])
 d.rectangle((16,y(11),23,y(19)),fill=P['skin'])
 d.rectangle((14,y(9),23,y(13)),fill=P['hairshade'])
 d.rectangle((15,y(7),22,y(12)),fill=P['hair'])
 d.rectangle((18,y(6),20,y(8)),fill=P['hair'])
 d.rectangle((22,y(8),25,y(11)),fill=P['hair'])
 d.rectangle((13,y(11),15,y(16)),fill=P['hairshade'])
 d.point((22,y(14)),fill=P['shadow'])
 d.point((24,y(17)),fill=P['skinshadow'])
 # cape brooch
 d.ellipse((12,y(19),15,y(22)),fill=P['steel']); d.point((13,y(20)),fill=P['shadow'])
 # arm shield and attack
 if kind=='attack':
  phase=i/n
  handx=22+round(2*math.sin(phase*math.pi)); hand_y=27-round(4*math.sin(phase*math.pi))
  d.line((22,y(23),handx+3,y(hand_y)),fill=P['leather'],width=4)
  d.rectangle((handx+1,y(hand_y)-1,handx+4,y(hand_y)+2),fill=P['skin'])
  if i in (1,2,3,4):
   sx=handx+4;sy=y(hand_y)
   d.line((sx,sy,sx+7,sy-8 if i<3 else sy+5),fill=P['steel'],width=2)
   d.point((sx+7,sy-8 if i<3 else sy+5),fill=P['white'])
  else:d.line((handx+3,y(hand_y),handx+6,y(hand_y)+8),fill=P['steel'],width=2)
  d.ellipse((10,y(23),17,y(32)),fill=P['shadow']);d.ellipse((11,y(24),16,y(31)),fill=P['wood'])
 else:
  d.rectangle((22,y(23),26,y(29)),fill=P['leather'])
  d.rectangle((23,y(27),27,y(31)),fill=P['skin'])
  d.ellipse((23,y(20),30,y(31)),fill=P['shadow']);d.ellipse((24,y(21),29,y(30)),fill=P['steel']);d.ellipse((25,y(22),28,y(29)),fill=P['wood']);d.line((26,y(23),26,y(28)),fill=P['glow'])
  if kind not in ('death','hurt'):
   d.line((12,y(31),10,y(39)),fill=P['steel'],width=2)
 if kind=='double_jump':
  # two cyan curved magical flourishes kept in sheet bounds
  d.arc((1,26,12,42),70,255,fill=P['glow'],width=1)
  d.arc((23,27,31,41),-85,110,fill=P['glow'],width=1)
 if kind=='hurt':
  d.point((29,y(16)), fill=P['cape']);d.point((8,y(14)),fill=P['cape'])
 if kind=='victory' and i%4>=2:
  d.line((25,y(24),30,y(7)), fill=P['steel'],width=2)
 if kind=='death' and i>2:
  # rotate in original canvas for last frames while retaining footer pixel
  im=im.rotate(70 if i<5 else 90,resample=Image.Resampling.NEAREST,center=(16,36))
 return im
anims={'idle':(4,6,True),'run':(8,10,True),'jump':(2,8,False),'fall':(2,8,True),'double_jump':(2,10,False),'land':(2,8,False),'attack':(6,10,False),'hurt':(2,7,False),'victory':(4,6,True),'death':(6,8,False)}
manifest={'pack':'RUNЕBOUND Hero Sprite Pack v1','frame_size':[32,48],'facing':'right','anchor':'bottom_center','feet_reference_pixel':[16,46],'layout':'horizontal strips, left-to-right, one row per animation','animations':{},'notes':['Integrate as visuals only; keep CharacterBody2D collider and movement scripts unchanged.','Nearest-neighbor filtering; PNG transparent backgrounds.','AnimatedSprite2D: load individual 32×48 regions in order, FPS as specified.','Weapon hitboxes are controlled by combat logic, not inferred from pixels.','Art is an original small-scale pixel-art implementation of the approved character design; review aesthetics in-engine before considering final.']}
for name,(count,fps,loop) in anims.items():
 sheet=Image.new('RGBA',(32*count,48))
 for i in range(count): sheet.alpha_composite(frame(name,i,count),(32*i,0))
 fn='hero_'+name+'.png';sheet.save(path+'/'+fn)
 manifest['animations'][name]={'file':'assets/characters/hero/'+fn,'frames':count,'fps':fps,'loop':loop}
 # frame pixel count and alpha
 assert sheet.getbbox() is not None
# overview
from PIL import ImageFont
preview=Image.new('RGB',(1056,880),'#263b44'); p=ImageDraw.Draw(preview)
p.text((25,16),'RUNEBOUND — HERO SPRITE PACK V1 | 32 x 48 / transparent PNG',fill='#f2e7d8')
y=64
for name,(count,fps,loop) in anims.items():
 p.text((24,y+13),f'{name.upper()}  ·  {count}f  ·  {fps}fps',fill='#e9be62')
 im=Image.open(path+'/hero_'+name+'.png')
 big=im.resize((im.width*3,im.height*3),Image.Resampling.NEAREST)
 # chessboard background beneath each animation
 for yy in range(0,big.height,16):
  for xx in range(0,big.width,16):
   p.rectangle((210+xx,y+yy,225+xx,y+yy+15),fill='#344b56' if (xx//16+yy//16)%2==0 else '#405761')
 preview.paste(big,(210,y),big)
 y+=160
 if y+145>preview.height:break
preview.save(out+'/preview.png')
with open(path+'/manifest.json','w') as f:json.dump(manifest,f,indent=2)
with open(out+'/README.md','w') as f:f.write('''# RUNEBOUND Hero Sprite Pack v1\n\nOriginal, game-ready-format **prototype** pixel sprites. All animation PNGs are transparent, arranged horizontally in 32×48 cells.\n\nSource is generated procedurally to ensure frame-perfect alignment and consistent palette; **not** extracted from the concept illustration. Visual quality is a first-pass stylized sprite, not final polished illustration.\n\n## Godot integration\nUse `AnimatedSprite2D` with `SpriteFrames` animations; slice each image horizontally into equal-width 32×48 frames. Set nearest texture filter and each animation's FPS from `manifest.json`. Face right by default, use `flip_h` for left. Place the AnimatedSprite2D relative to player collider, with bottom-center of the frame as feet. Keep combat/physics independent.\n\n## Do not\nDo not treat the picture reference poster as a sprite sheet. Do not change physics/collision to fit cape/sword.\n''')
with zipfile.ZipFile('/mnt/data/RUNEBOUND_Hero_Sprite_Pack_v1.zip','w',zipfile.ZIP_DEFLATED) as z:
 for root,_,files in os.walk(out):
  for fn in files:z.write(os.path.join(root,fn),os.path.relpath(os.path.join(root,fn),out))
print('created',os.listdir(path))
