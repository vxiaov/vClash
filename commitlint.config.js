module.exports = {
    extends: ['@commitlint/config-conventional'],
    rules: {
        // level[0..2]: 0表示禁用规则，1为警告，2为错误
        // Appliable : always 适用此规则， never反转规则
        // Value 用于此规则的值
        'body-leading-blank': [2, 'always'], // body 开始于空白行
        'header-max-length': [2, 'always', 72], // header 字符最大长度为 72
        'subject-full-stop': [0, 'never'], // subject 结尾不加 '.'
        'type-empty': [2, 'never'], // type字段不可以为空
        'type-enum': [2, 'always', [
            'feat', // 新特性、需求
            'fix', // bug 修复
            'docs', // 文档内容改动
            'style', // 不影响代码含义的改动，例如去掉空格、改变缩进、增删分号
            'refactor', // 代码重构
            'test', // 添加或修改测试
            'chore', // 不修改 src 或者 test 的其余修改，例如构建过程或辅助工具的变动
            'revert', // 执行 git revert 打印的 message
            'build', // 影响构建系统或外部依赖项的更改（示例范围：gulp、broccoli、npm）
        ]],
    }
};
