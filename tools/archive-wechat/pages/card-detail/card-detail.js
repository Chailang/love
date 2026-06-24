
const { mockUsers } = require('../../utils/mockData.js')

Page({
  data: {
    user: null
  },

  onLoad: function (options) {
    const id = parseInt(options.id)
    const user = mockUsers.find(u => u.id === id)
    this.setData({
      user: user
    })
    console.log('打开详情页：', user)
  },

  onNope: function() {
    wx.showToast({
      title: '已跳过',
      icon: 'success',
      success: () => {
        setTimeout(() => {
          wx.navigateBack()
        }, 500)
      }
    })
  },

  onLike: function() {
    wx.showToast({
      title: '❤️ 喜欢成功！',
      icon: 'success',
      success: () => {
        setTimeout(() => {
          wx.navigateBack()
        }, 800)
      }
    })
  }
})
