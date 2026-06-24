
const { mockUsers, mockDiscover } = require('../../utils/mockData.js')

Page({
  data: {
    categories: mockDiscover,
    users: mockUsers
  },

  onLoad: function () {
    console.log('发现页加载完成')
  },

  onCategoryTap: function(e) {
    const id = e.currentTarget.dataset.id
    wx.showToast({
      title: `打开${this.data.categories.find(c => c.id === id).title}`,
      icon: 'none'
    })
  },

  onUserTap: function(e) {
    const id = e.currentTarget.dataset.id
    wx.navigateTo({
      url: `/pages/card-detail/card-detail?id=${id}`
    })
  }
})
