
Page({
  data: {

  },

  onLoad: function () {
    console.log('个人中心页加载完成')
  },

  onEdit: function() {
    wx.showToast({
      title: '编辑资料（演示版）',
      icon: 'none'
    })
  },

  onMenuTap: function(e) {
    const name = e.currentTarget.dataset.name
    wx.showToast({
      title: `${name}（演示版）`,
      icon: 'none'
    })
  }
})
