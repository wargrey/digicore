/**
 * 培养学生编写规范代码和规范注释很有必要：
 *  1. 好记性不如烂笔头。
 *      1. 永远不要相信学生“在脑子里解题”；
 *      2. 书写的过程就是整理思路的过程，中文都表达不出来，必然不可能写成代码。
 *  2. 源码是义务教育阶段学生唯一可靠的复习资料。
 *      1. 大部分学生不会主动看书；
 *      2. 部分学生习惯性把教师打印的资料归档在一起，但又不随电脑一起携带；
 *      3. 部分学生在家都是家长保管打印的资料，更难做到“随想随看”；
 *      4. 如果学生主动(或在监督情况下)上机，他们自己写过的代码应该包含所有重要信息；
 *      5. 计算机工程有一整套源码、文档管理方案，本来就不依赖纸笔笔记。
 * 
 * 带 main 函数的源码文件格式规定：
 *  1. 此文件所要解决的问题以双星号(**)注释块的形式写在第一行正式代码的前面
 *      1. 此注释不必是第一个注释块。比如 本文件的第一个注释块就不包含题目信息
 *      2. 在真实的软件项目里，第一个注释块可能是项目信息、版权信息等优先级更高的信息
 *      3. 此注释块的每一行都需要有个星号(*)以保持格式美观，不过靠谱的编辑器会自动帮你加星号
 *  2. 后面接上正式代码，main 函数放在文件最后。
 * 
 * 授课流程 [根据学生具体情况，流程2和3的顺序可自由发挥，通常会交错展开]：
 *  1. 确定问题，补全“题目信息”注释块
 *  2. 编写程序，重复“运行-出错-修改”循环，直到程序通过所有测试
 *      1. 定义变量
 *          1. 按需要将输入参数声明为程序变量
 *          2. 根据题目信息，提炼出其他需要定义的变量
 *      2. 输入: 从标准输入读取信息初始化输入参数(和相关变量)
 *      3. 处理: 围绕上述变量设计算法求解问题
 *      4. 输出: 按要求输出求解结果
 *  3. 重构程序，突出程序的逻辑线
 *      1. 如果还没开始写代码(自顶向下)
 *          1. 可将题目中的重要信息提炼成函数
 *      2. 如果已经完成可运行的代码(自底向上)
 *          1. 可将程序中比较难懂的代码抽象成函数
 *          2. 可将程序中重复的代码抽象成函数
 */

/** 这个注释用于健壮性测试，不用管。如果运行测试程序没看到测试结果，说明这行注释绊倒了测试程序 */
/*! 同上 */

// 下一个注释块演示“题目信息”注释的书写规范

/** [这里接题目的简短名称，可省略] 例如: 测试驱动计算
 * 
 * [这里可以以多个段落给出完整的问题，不建议省略]
 * 特别说明, 题目可能很啰嗦，因此：
 *  1. 对于初级班，学生存在键盘熟练度问题，那就干脆给他们时间借助题目练习打字
 *  2. 对于高级班，学生键盘已经很熟练的情况下，可以从教师源码里直接复制过来
 * 
 * [接下来是问题的输入-输出说明]
 * 为避免与函数的参数-返回值说明语法混淆，建议
 *  1. 使用 @arg 声明程序输入
 *      1. 每个参数都要有一个 @arg
 *      2. 一般不会出现“无输入参数”的情况。
 *          1. 如果有，那也用不着费这个劲请测试程序出马了
 *      3. 输入参数必须说清楚参数的类型
 *  2. 使用 @result 声明程序输出
 *      1. 如果输出不重要可省略
 *          1. 考虑对话类的程序，它们说了一堆给用户看的人话，此时你的眼睛比测试程序更靠谱
 * 
 * 虽然题目通常会直接给出程序的输入和输出说明，
 * 但为确保学生真的跟上了教学节奏，
 * 这部分内容必须由学生自己从原题中提炼，
 * 学生尤其要重视各个参数的约束条件。
 *  
 * @arg [输入参数1的简短说明] 例如: type 正整数 测试类型编号
 * @arg [输入参数2的简短说明] 例如: data 自定义类型 此测试用例实际用到的数据
 * @result [输出结果的简短说明] 例如: 将输入数据转化为浮点数，保留一位小数
 * 
 * [接下来就题目的测试用例]
 * 一般来说，每到题目至少有两个测试用例
 *  1. 第一个测试用例由题目直接给出
 *  2. 第二个测试用例由教师或学生给输入，然后学生根据题目要求自己纸笔推演出正确的输出
 *  3. 学有余力的学生可自行添加其他测试用例，用以检查算法的边界条件、容错能力等
 * 
 * 测试用例书写规范：
 *  1. 输入参数跟在 input 行后面，直到碰到其他可以指示注释结构的行
 *  2. 输出参数跟在 output 行后面，直到碰到其他可以指示注释结构的行
 *  3. 测试用例可以保存在别的文件里
 *      1. 文件用 @file 或 @include 声明
 *      2. 相当于把文件内容复制插入到声明它们的那一行
 *      3. 文件的相对路径相对于声明它的源码文件，与 `#include ""`相同
 *  4. 输入和输出的内容【不】包含它们各自内容前后的空行
 *  5. 如果有多个 input 或 output, 它们各自的内容将合并到一起
 *      1. input 和 output 可以交错出现
 *      2. input 和 output 之外的内容的会被忽略
 *  6. 如果省略 input 和 output，则输入和输出以空行分隔
 *      1. 没有空行时默认所有内容均为输入
 *      2. 不建议学生省略 input 和 output
 *  7. 测试用例的输入参数和输出参数应当符合上述 @arg 和 @result 的说明
 * 
 * @test 这是题目给出的标准测试用例
 * input:
 * 0 4
 * output:
 * 4.0
 * 
 * @test 这是学生纸笔推演出的测试用例
 * output:
 * -2.0
 * input:
 * 0 -2
 * 
 * @test 这个测试用例有 output，但是要求“不输出任何东西”
 * input:
 * 1
 * output:
 * 
 * @test 话唠测试用例从不需要说明 output
 * input:
 * 2
 * 
 * @test 懒惰的测试用例会省略 input 和 output。你得去猜，哎~，就是玩!
 * 0 128.0
 * 
 * 128.0
 *
 * @test 懒惰的外部测试用例。其内容来自两个文件，中间的空行说明这两个文件分别提供输入和输出数据
 * @file stone/readme.in

 * @file stone/readme.ans
 * 
 * @test 懒惰又易错的测试用例。它省略了 input 和 output，但又企图只给 output，结果翻车了吧？
 * 
 * 3
 * 
 * @test 空测试用例算做“待测用例”，不计入失败的测试
 **/

/*************************************************************************************************/
#include <iostream> /* 标准输入输出头文件 */

/**
 * 程序入口必须命名为 `main`
 * 
 * @param argc, "argument count" 的缩写，即"参数个数"
 * @param argv, "argument vector" 的缩写, 即"参数数组"，包含命令行的所有输入参数
 * @return status, 0 表示程序正常结束，其他数字可用来指示出错原因
 */
int main(int argc, char* argv[]) {
    /** 根据题目要求声明变量 */
    unsigned int type = 255;    // 测试类型
    int z;                      // 主测试数据
    int status = 0;             // 程序状态，默认0
    
    std::cin >> type;           // EOF 不会修改 type

    switch (type) {
    case 0: { // 主测试，整数转浮点数
        std::cin >> z;
        printf("%.1f", float(z)); // std::cout 真不是个东西
    }; break;
    case 1: std::cout << "哼, 战斗力只有5的渣渣!"; break;              // “沉默”咒术
    case 2: std::cout << "毁灭吧，赶紧的，累了。"; break;               // 打断"沉默", 全异常解除
    case 3: std::cerr << "预期的输出被当成了输入！"; status = 3; break; // 只好让程序本身报告错误了
    default: status = type;
    }

    // 任务完成，C++ 心满意足地退出
    return status;
}
