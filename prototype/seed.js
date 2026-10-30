// 课程虚构数据；与 SQL 种子数据的五个展览对应，不读取本机数据库。
export const exhibitions = [
  { id:1, title:'厦园有光', introduction:'山海之间的青年创作展', cover:'/assets/厦园晨雾.png', status:'on_view', visible:true, startsAt:'2026-10-20T09:00', endsAt:'2026-11-06T18:00', statement:'在红瓦与海风之间，收集厦园细微的日常。这场展览以建筑、湖面、花木与海岸为线索，让不同的创作在同一片校园里相遇。\n\n我们邀请观众放慢脚步，重新看见熟悉的窗、光与影。展览内容与作者均为课程虚构演示数据。' },
  { id:2, title:'凤凰花开的季节', introduction:'校园植物与日常的视觉记录', cover:'/assets/凤凰花季.png', status:'collecting', visible:true, startsAt:'2026-11-20T09:00', endsAt:'2026-12-06T18:00', statement:'从一树凤凰花开始，记录季节与校园共同生长的颜色。以视觉创作为语言，连接日常观察和青年表达。此为课程演示展览。' },
  { id:3, title:'瓦影与窗', introduction:'嘉庚建筑视觉设计展', cover:'/assets/瓦影.png', status:'archived', visible:true, startsAt:'2026-09-20T09:00', endsAt:'2026-10-10T18:00', statement:'沿着嘉庚建筑的轮廓，寻找瓦片、窗框与光影中的节奏。此档案保留已结束展览的线上介绍，供观众继续浏览。' },
  { id:4, title:'向海而生', introduction:'海岸、风与青年视野的视觉记录', cover:'/assets/向海.png', status:'on_view', visible:false, startsAt:'2026-10-20T09:00', endsAt:'2026-11-06T18:00', statement:'尚未公开的课程演示展览。' },
  { id:5, title:'窗与海的对话', introduction:'从一扇窗出发，发现校园与海的关系', cover:'/assets/瓦影.png', status:'draft', visible:false, startsAt:'2026-12-01T09:00', endsAt:'2026-12-20T18:00', statement:'' },
].map(item => ({ ...item, venue:'校园线上展厅' }))
export const works = [
  {id:1,title:'窗的秩序',author:'临舟',image:'/assets/瓦影.png'},
  {id:2,title:'红瓦的几何',author:'云序',image:'/assets/凤凰花季.png'},
  {id:3,title:'湖面留白',author:'知夏',image:'/assets/厦园晨雾.png'},
  {id:4,title:'海风的形状',author:'南汐',image:'/assets/向海.png'},
].map(item => ({...item, medium:'视觉创作'}))
