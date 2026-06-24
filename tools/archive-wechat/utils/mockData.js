
// 本地假数据
const mockUsers = [
  {
    id: 1,
    name: '小甜甜',
    age: 26,
    height: 168,
    education: '硕士',
    job: '产品经理',
    location: '北京朝阳区',
    distance: '3km',
    avatar: 'https://via.placeholder.com/300x400/f8e8e8/333?text=😊',
    photos: [
      'https://via.placeholder.com/300x400/f8e8e8/333?text=Photo+1',
      'https://via.placeholder.com/300x400/e8f0f8/333?text=Photo+2',
      'https://via.placeholder.com/300x400/f0e8f8/333?text=Photo+3'
    ],
    tags: ['温柔', '爱旅行', '看电影'],
    aboutMe: '喜欢旅游和美食，希望找到一个三观一致的你～'
  },
  {
    id: 2,
    name: '阳光大男孩',
    age: 29,
    height: 183,
    education: '本科',
    job: '软件开发工程师',
    location: '北京海淀区',
    distance: '5km',
    avatar: 'https://via.placeholder.com/300x400/e0f0e8/333?text=😎',
    photos: [
      'https://via.placeholder.com/300x400/e0f0e8/333?text=Avarta+1',
      'https://via.placeholder.com/300x400/e8e8f0/333?text=Sport'
    ],
    tags: ['健身', '编程', '爬山'],
    aboutMe: '程序员一枚，爱好健身和户外，希望认识有趣的你'
  },
  {
    id: 3,
    name: '奶茶少女',
    age: 24,
    height: 162,
    education: '本科',
    job: '设计师',
    location: '北京西城区',
    distance: '2km',
    avatar: 'https://via.placeholder.com/300x400/f8e8f8/333?text=🍰',
    photos: [
      'https://via.placeholder.com/300x400/f8e8f8/333?text=Design',
      'https://via.placeholder.com/300x400/f5f8e8/333?text=Coffee'
    ],
    tags: ['设计', '美食', '养猫'],
    aboutMe: '喜欢画画和探店，每天一杯奶茶快乐无边~'
  },
  {
    id: 4,
    name: '张医生',
    age: 31,
    height: 178,
    education: '博士',
    job: '医生',
    location: '北京东城区',
    distance: '6km',
    avatar: 'https://via.placeholder.com/300x400/e8f0f0/333?text=⚕️',
    photos: [
      'https://via.placeholder.com/300x400/e8f0f0/333?text=Doctor'
    ],
    tags: ['医学', '读书', '钢琴'],
    aboutMe: '三甲医院医生，生活规律，期待相遇'
  },
  {
    id: 5,
    name: '夏夏',
    age: 25,
    height: 165,
    education: '本科',
    job: '老师',
    location: '北京海淀区',
    distance: '4km',
    avatar: 'https://via.placeholder.com/300x400/fff0f0/333?text=👧',
    photos: [
      'https://via.placeholder.com/300x400/fff0f0/333?text=Teacher',
      'https://via.placeholder.com/300x400/f0fff0/333?text=Reading'
    ],
    tags: ['教育', '读书', '瑜伽'],
    aboutMe: '大学老师，假期多多，喜欢安静的生活'
  }
]

const mockMessages = [
  {
    id: 1,
    userId: 1,
    name: '小甜甜',
    avatar: 'https://via.placeholder.com/80x80/f8e8e8/333?text=😊',
    lastMsg: '周末你一般喜欢做什么呢？',
    time: '09:24',
    unread: 2
  },
  {
    id: 2,
    userId: 3,
    name: '奶茶少女',
    avatar: 'https://via.placeholder.com/80x80/f8e8f8/333?text=🍰',
    lastMsg: '这家咖啡馆真的不错',
    time: '昨天',
    unread: 0
  },
  {
    id: 3,
    userId: 5,
    name: '夏夏',
    avatar: 'https://via.placeholder.com/80x80/fff0f0/333?text=👧',
    lastMsg: '我也很喜欢看这本书',
    time: '周一',
    unread: 1
  }
]

const mockDiscover = [
  {
    id: 1,
    title: '兴趣相投',
    icon: '🎯',
    count: 128
  },
  {
    id: 2,
    title: '附近的人',
    icon: '📍',
    count: 56
  },
  {
    id: 3,
    title: '高颜值',
    icon: '✨',
    count: 234
  },
  {
    id: 4,
    title: '高学历',
    icon: '🎓',
    count: 89
  }
]

module.exports = {
  mockUsers,
  mockMessages,
  mockDiscover
}
