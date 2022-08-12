// changelog 配置，commit 规则也在这里进行配置
// 参考文档：https://www.npmjs.com/package/git-cz

module.exports = {
  disableEmoji: true,
  // format: '{type}{scope}: {emoji}{subject}',
  list: ['test', 'feat', 'fix', 'chore', 'docs', 'refactor', 'style', 'ci', 'perf'],
  maxMessageLength: 64,
  minMessageLength: 3,
  questions: ['type', 'scope', 'subject', 'body', 'breaking', 'issues', 'lerna'],
  scopes: [],
  types: {
    chore: {
      description: '一些与主要业务无关的构建/工程依赖/工具等功能改动',
      emoji: '🤖',
      value: 'chore'
    },
    ci: {
      description: 'CI related changes',
      emoji: '🎡',
      value: 'ci'
    },
    docs: {
      description: '文档更新(如：README)',
      emoji: '✏️',
      value: 'docs'
    },
    feat: {
      description: '新的特性',
      emoji: '🎸',
      value: 'feat'
    },
    fix: {
      description: 'bug 修复',
      emoji: '🐛',
      value: 'fix'
    },
    perf: {
      description: '优化了性能的代码改动',
      emoji: '⚡️',
      value: 'perf'
    },
    refactor: {
      description: '一些代码结构上优化，既不是新特性也不是修 Bug',
      emoji: '💡',
      value: 'refactor'
    },
    release: {
      description: 'Create a release commit',
      emoji: '🏹',
      value: 'release'
    },
    style: {
      description: '代码的样式美化，不涉及到功能修改等',
      emoji: '💄',
      value: 'style'
    },
    test: {
      description: '新增或修改已有的测试代码',
      emoji: '💍',
      value: 'test'
    }
  }
};

