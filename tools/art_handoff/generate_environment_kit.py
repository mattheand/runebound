from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import random, json, shutil, zipfile, math
random.seed(41)
root=Path('/mnt/data/RUNEBOUND_Art_Handoff_v1'); root.mkdir(exist_ok=True)
for p in ['assets/characters','assets/environments/midgard','assets/collectibles','assets/interactables','docs/design','docs/handoff','tools']:(root/p).mkdir(parents=True,exist_ok=True)
source=Path('/mnt/data/RUNEBOUND_Hero_Sprite_Pack_v1')
shutil.copytree(source/'assets/characters/hero',root/'assets/characters/hero',dirs_exist_ok=True)
shutil.copy(source/'tools/generate_sprites.py',root/'tools/generate_hero_sprites.py')
shutil.copy(source/'preview.png',root/'docs/design/hero_sprite_preview.png')
for n,src in [('01_hero_character.webp','01_hero_character.webp'),('02_fjord_environment.webp','02_fjord_environment.webp'),('03_level_layout.webp','03_level_layout.webp'),('04_boss_encounter.webp','04_boss_encounter.webp'),('contact_sheet.webp','contact_sheet.webp')]:shutil.copy(Path('/mnt/data/RUNEBOUND_Visual_References')/src,root/'docs/design'/n)
shutil.copy('/mnt/data/runebound_viking_hero_reference_sheet.png',root/'docs/design/hero_reference_approved.png')
shutil.copy('/mnt/data/RUNEBOUND_Visual_References/ART_DIRECTION.md',root/'docs/design/ART_DIRECTION.md')
W,H=640,360
# generated independent RGBA parallax layers, no concept screenshot crops
sky=Image.new('RGBA',(W,H),(0,0,0,0)); d=ImageDraw.Draw(sky)
for y in range(H):
 t=y/H; d.line((0,y,W,y),fill=(int(118+64*t),int(183+33*t),int(225+15*t),255))
d.ellipse((477,30,519,72),fill=(255,235,186,255));d.ellipse((482,35,515,68),fill=(255,246,209,255))
for x,y,rx in [(65,58,28),(190,78,35),(390,53,32),(557,109,24)]:
 for dx,dy,r in [(-rx//2,0,rx//2),(0,-9,rx//2),(rx//2,0,rx//2)]:d.ellipse((x+dx-r,y+dy-r//2,x+dx+r,y+dy+r//2), fill=(236,243,245,210))
sky.save(root/'assets/environments/midgard/sky_640x360.png')
mount=Image.new('RGBA',(W,H)); d=ImageDraw.Draw(mount)
points=[(-40,265),(10,198),(55,225),(108,130),(161,205),(210,155),(245,187),(315,108),(366,184),(406,145),(458,200),(519,122),(575,185),(640,145),(680,265)]
d.polygon(points+[(680,360),(-40,360)],fill=(117,154,175,255))
for x,y in points[1:-1]:
 if y<185:d.polygon([(x-19,y+23),(x,y),(x+21,y+25),(x+9,y+17),(x,y+11),(x-7,y+15)],fill=(224,233,232,255))
for i in range(42):
 x=random.randrange(W);y=random.randrange(235,360);r=random.randrange(8,28)
 d.polygon([(x-r,y+r),(x,y-r),(x+r,y+r)],fill=(101,143,164,255))
mount.save(root/'assets/environments/midgard/mountains_640x360.png')
fjord=Image.new('RGBA',(W,H));d=ImageDraw.Draw(fjord)
d.polygon([(0,258),(100,270),(220,245),(360,267),(510,255),(640,274),(640,360),(0,360)],fill=(78,147,174,255))
for i in range(110):
 x=random.randrange(W);y=random.randrange(269,360);d.line((x,y,x+random.randrange(4,23),y),fill=(155,204,216,random.randrange(70,160)))
d.polygon([(0,247),(60,233),(115,259),(148,292),(0,312)],fill=(66,103,102,255));d.polygon([(498,275),(548,247),(640,222),(640,329)],fill=(60,100,100,255))
fjord.save(root/'assets/environments/midgard/fjord_640x360.png')
forest=Image.new('RGBA',(W,H));d=ImageDraw.Draw(forest)
for x in range(-15,670,21):
 y=random.randrange(234,278);h=random.randrange(24,75); ww=random.randrange(8,19)
 d.rectangle((x-2,y-h//2,x+2,y),fill=(40,71,72,255))
 for j in range(3):
  top=y-h+j*int(h*.18);d.polygon([(x,top),(x-ww+j*2,top+h//2),(x+ww-j*2,top+h//2)],fill=random.choice([(32,78,78,255),(36,88,81,255),(42,93,84,255)]))
forest.save(root/'assets/environments/midgard/forest_640x360.png')
# 16x16 tiles, 8 columns (128x16) with descriptive manifest
colors={'stone':'#3d5055','deep':'#263b44','moss':'#648850','light':'#a4b56a','wood':'#765138','wood_l':'#af8250'}
tiles=Image.new('RGBA',(16*8,16)); td=ImageDraw.Draw(tiles)
for idx,typ in enumerate(['grass_top','dirt','stone','stone_cracked','moss_stone','wood_plank','wood_end','rune_stone']):
 x=idx*16;td.rectangle((x,0,x+15,15),fill=colors['deep'])
 if typ in ('grass_top','dirt','moss_stone'):
  td.rectangle((x+1,1,x+14,14),fill=colors['stone']);
  for k in range(7):
   a=x+random.randrange(2,14);b=random.randrange(3,14); td.point((a,b),fill='#57716a')
  if typ!='dirt':td.rectangle((x,0,x+15,3),fill=colors['moss']);td.line((x+2,0,x+13,0),fill=colors['light'])
 elif typ.startswith('stone') or typ=='rune_stone':
  td.rectangle((x+1,1,x+14,14),fill='#526268');td.line((x+1,8,x+14,8),fill=colors['deep']);td.line((x+7,1,x+7,8),fill=colors['deep'])
  if typ=='stone_cracked':td.line((x+4,2,x+9,6,x+6,12),fill='#172d35',width=1)
  if typ=='rune_stone':td.line((x+7,3,x+7,12),fill='#55d7ff');td.line((x+4,5,x+10,9,x+5,12),fill='#55d7ff')
 else:
  td.rectangle((x+1,2,x+14,13),fill=colors['wood']);td.line((x+2,5,x+14,5),fill=colors['wood_l']);td.line((x+2,10,x+14,10),fill='#453528')
  td.ellipse((x+3,3,x+4,4),fill='#b0a18b');td.ellipse((x+11,11,x+12,12),fill='#b0a18b')
  if typ=='wood_end':td.rectangle((x+1,1,x+3,14),fill='#b18b62')
tiles.save(root/'assets/environments/midgard/terrain_tiles_16.png')
# Rune & checkpoint frame sheets
runes=Image.new('RGBA',(16*6,16)); d=ImageDraw.Draw(runes)
for i in range(6):
 x=i*16;dy=[1,0,-1,0,1,2][i];glow=[100,140,190,230,170,110][i]
 d.polygon([(x+8,2+dy),(x+13,7+dy),(x+8,14+dy),(x+3,7+dy)],fill=(38,128,198,255),outline=(81,219,255,255))
 d.line([(x+8,4+dy),(x+8,11+dy),(x+5,7+dy),(x+11,7+dy)],fill=(234,252,255,255))
 d.point((x+2,3+dy),fill=(98,213,255,glow))
runes.save(root/'assets/collectibles/rune_pickup_16x16_6f.png')
cp=Image.new('RGBA',(32*4,48));d=ImageDraw.Draw(cp)
for i in range(4):
 x=i*32;d.rectangle((x+14,8,x+17,47),fill='#8b6042'); d.rectangle((x+12,8,x+21,10),fill='#bd8d58')
 d.polygon([(x+18,9),(x+29,13),(x+27,29),(x+18,24)],fill='#9d303c' if i==0 else '#c6454b')
 d.line([(x+22,15),(x+25,20),(x+22,23),(x+22,15)],fill='#e4c3ae' if i==0 else '#7cddff')
 if i:d.ellipse((x+20,13,x+27,23),outline=(84,215,255,100+i*50),width=1)
cp.save(root/'assets/interactables/checkpoint_flag_32x48_4f.png')
asset_manifest={'version':'1.0.0','status':'prototype production-format, not final illustrated quality','hero':{'frame':[32,48],'reference':'docs/design/hero_reference_approved.png','manifest':'assets/characters/hero/manifest.json'},'environment':{'logical_canvas':[640,360],'layers_back_to_front':['sky_640x360.png','mountains_640x360.png','fjord_640x360.png','forest_640x360.png'],'tilesize':[16,16],'tiles':['grass_top','dirt','stone','stone_cracked','moss_stone','wood_plank','wood_end','rune_stone'],'tile_atlas':'assets/environments/midgard/terrain_tiles_16.png','repeat':'not guaranteed seamless; static scene backdrop usable, wrap/repeat requires editing'},'rune_pickup':{'sheet':'assets/collectibles/rune_pickup_16x16_6f.png','size':[16,16],'frames':6,'fps':8},'checkpoint':{'sheet':'assets/interactables/checkpoint_flag_32x48_4f.png','size':[32,48],'frames':4,'fps':5},'license':'Original procedurally created assets in this package; review project-wide licensing before public release'}
(root/'asset_manifest.json').write_text(json.dumps(asset_manifest,indent=2))
# visual contact sheet from actual output
bg=Image.new('RGBA',(640,360));
for f in asset_manifest['environment']['layers_back_to_front']:bg.alpha_composite(Image.open(root/'assets/environments/midgard'/f))
preview=Image.new('RGB',(1280,740),'#172b36');preview.paste(bg.resize((1280,720),Image.Resampling.NEAREST),(0,0));
from PIL import ImageFont
q=ImageDraw.Draw(preview);q.rectangle((0,0,1280,36),fill='#182f3f');q.text((14,10),'RUNEBOUND  •  MIDGARD ENVIRONMENT LAYER STUDY  •  640x360',fill='#f0eacb');preview.save(root/'environment_preview.png')
