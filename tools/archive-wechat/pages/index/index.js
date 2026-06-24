
const { mockUsers } = require('../../utils/mockData.js')

Page({
  data: {
    users: [],
    currentIndex: 0,
    translateX: 0,
    transform: 'translate(0, 0) rotate(0deg)',
    cardHeight: 0,
    loading: true,
    noMore: false
  },

  onLoad: function () {
    // 计算卡片高度
    const systemInfo = wx.getSystemInfoSync()
    // 减去顶部标题栏和底部操作栏高度
    const cardHeight = systemInfo.windowHeight - 88 - 160 - systemInfo.statusBarHeight
    this.setData({
      users: mockUsers,
      cardHeight: cardHeight,
      loading: false
    })
    console.log('加载用户数据:', mockUsers.length, '个')
  },

  // 触摸开始
  onTouchStart: function(e) {
    if (this.data.currentIndex !== e.currentTarget.dataset.index) return
    this.startX = e.touches[0].clientX
    this.startY = e.touches[0].clientY
  },

  // 触摸移动
  onTouchMove: function(e) {
    if (this.data.currentIndex !== e.currentTarget.dataset.index) return
    
    const moveX = e.touches[0].clientX - this.startX
    const moveY = e.touches[0].clientY - this.startY
    const rotate = moveX / 10
    
    this.setData({
      translateX: moveX,
      transform: `translate(${moveX}px, ${moveY * 0.3}px) rotate(${rotate}deg)`
    })
  },

  // 触摸结束
  onTouchEnd: function(e) {
    if (this.data.currentIndex !== e.currentTarget.dataset.index) return
    
    const translateX = this.data.translateX
    
    // 判断滑动方向
    if (Math.abs(translateX) > 100) {
      // 超出阈值，滑走
      const direction = translateX > 0 ? 1 : -1
      this.swipeCard(direction)
    } else {
      // 回弹
      this.resetPosition()
    }
  },

  // 滑动卡片
  swipeCard: function(direction) {
    const screenWidth = wx.getSystemInfoSync().windowWidth
    const endX = direction * screenWidth
    const rotate = direction * 30
    
    this.setData({
      transform: `translate(${endX}px, 0) rotate(${rotate}deg)`
    })
    
    // 喜欢/不喜欢提示
    if (direction > 0) {
      wx.showToast({
        title: '喜欢❤️',
        icon: 'none',
        duration: 500
      })
    } else {
      wx.showToast({
        title: '跳过',
        icon: 'none',
        duration: 500
      })
    }
    
    // 动画结束后下一张
    setTimeout(() => {
      const nextIndex = this.data.currentIndex + 1
      this.setData({
        currentIndex: nextIndex,
        translateX: 0,
        transform: 'translate(0, 0) rotate(0deg)',
        noMore: nextIndex >= this.data.users.length
      })
    }, 300)
  },

  // 重置位置
  resetPosition: function() {
    this.setData({
      translateX: 0,
      transform: 'translate(0, 0) rotate(0deg)'
    })
  },

  // 按钮点击 - 不喜欢
  onNope: function() {
    this.swipeCard(-1)
  },

  // 按钮点击 - 喜欢
  onLike: function() {
    this.swipeCard(1)
  },

  // 超级喜欢
  onSuperLike: function() {
    wx.showToast({
      title: '⭐ 超级喜欢！',
      icon: 'none',
      duration: 1000
    })
    this.swipeCard(1)
  },

  // 刷新列表
  refreshList: function() {
    this.setData({
      currentIndex: 0,
      noMore: false
    })
    wx.showToast({
      title: '已刷新',
      icon: 'success'
    })
  },

  onFilter: function() {
    wx.showToast({
      title: '筛选功能（演示版）',
      icon: 'none'
    })
  }
})
