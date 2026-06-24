
const { mockMessages } = require('../../utils/mockData.js')

Page({
  data: {
    messages: mockMessages
  },

  onLoad: function () {
    console.log('消息页加载完成')
  },

  onMessageTap: function(e) {
    const id = e.currentTarget.dataset.id
    wx.showToast({
      title: '进入聊天页面（演示版）',
      icon: 'none'
    })
  }
})
