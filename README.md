# MyClock README

## 1. 当前仓库当中已有的模块与项目结构

### 1.1 当前项目结构

```text
MyClock/
├── README.md
├── src/
│   ├── clock_core.v
│   ├── time_core.v
│   ├── second_counter.v
│   ├── hour_counter.v
│   └── bcd_to_7_seg.v
└── VHD/
    ├── second.vhd
    ├── hour.vhd
    ├── set_min.vhd
    ├── set_hour.vhd
    ├── ring.vhd
    └── light.vhd
```

说明：

- `src/` 是当前版本后续继续开发的主目录。
- `VHD/` 来自于往届的部分功能实现代码，主要作为历史实现和思路参考，不作为这次协作开发的直接修改对象。

### 1.2 这个仓库当中已有的 Verilog 模块分别做什么

#### `src/clock_core.v`

当前定位：顶层模块。

应当承担的职责是：

- 对外提供实验箱需要的统一输入输出接口
- 当前已经实例化普通走时核心 `time_core`
- 作为后续设时、闹钟、倒计时功能接入的统一入口
- 负责后续模式切换、显示选择、响铃输出仲裁

不建议继续把复杂功能直接写进 `clock_core` 内部。  
应该把它当作“顶层接线层”和“功能调度层”。

#### `src/time_core.v`

当前定位：普通走时核心。

它主要负责：

- 维护当前正常时间
- 组织秒、分、时三级计数
- 提供当前时间给其他功能读取

后续约定：

- 当前时间只由 `time_core` 维护
- 设时功能通过接口写回 `time_core`
- 闹钟功能只读取 `time_core` 的当前时间
- 倒计时功能不依赖 `time_core` 内部状态

#### `src/second_counter.v`

当前定位：两位 BCD 计数模块。

负责内容：

- 秒计数或分钟计数
- 范围为 `00` 到 `59`
- 处理个位进位到十位

#### `src/hour_counter.v`

当前定位：小时计数模块。

负责内容：

- 小时计数
- 范围为 `00` 到 `23`
- 处理 `23 -> 00` 回绕

#### `src/bcd_to_7_seg.v`

当前定位：译码显示模块。

负责内容：

- 将 BCD 数字转换成七段码
- 提供数码管显示所需编码

### 1.3 之后的开发边界

为了让后续三项功能可以并行推进，默认边界如下：

- `clock_core.v` 负责统一接线和顶层接口
- `time_core.v` 只负责普通走时
- 设时功能后续建议新建 `src/set_time_core.v`
- 闹钟功能后续建议新建 `src/alarm_core.v`
- 倒计时功能后续建议新建 `src/countdown_core.v`

后续新增功能尽量不要直接改 `time_core` 的正常走时逻辑，也不要把逻辑继续堆到 `clock_core` 里。

### 1.4 当前 `clock_core` 中已有接口与预留接口


```verilog
input        clk;
input        clr;
input        tick;

input  [2:0] mode_sel;

input        ui_select;
input        ui_inc;
input        ui_dec;
input        ui_confirm;
input        ui_start;
input        ui_pause;
input        ui_stop;

input        alarm_enable_sw;

input        set_en;
input  [3:0] set_low;
input  [3:0] set_high;

output [6:0] seg_sec_low;
output [3:0] bcd_sec_high;
output [3:0] bcd_min_low;
output [3:0] bcd_min_high;
output [3:0] bcd_hour_low;
output [3:0] bcd_hour_high;
output       ring;
```

这组接口的作用：

- `mode_sel`：区分普通显示、设时、闹钟、倒计时等模式
- `ui_select / ui_inc / ui_dec / ui_confirm`：作为通用操作接口，后续给设时、闹钟、倒计时共用
- `ui_start / ui_pause / ui_stop`：主要给倒计时使用，也可用于停止响铃
- `alarm_enable_sw`：作为闹钟总开关
- `set_en / set_low / set_high`：当前原型中保留的设值相关接口，当前仍建议保留，但在现阶段普通走时核心中还没有完全接通
- `ring`：作为统一响铃输出，当前主要是为后续闹钟和倒计时功能预留

推荐模式编码如下：

- `3'b000`：普通走时显示
- `3'b001`：设时模式
- `3'b010`：闹钟设置或查看模式
- `3'b011`：倒计时设置模式
- `3'b100`：倒计时运行模式
- `3'b101`：保留
- `3'b110`：保留
- `3'b111`：保留

补充说明：

- `set_en` 是当前原型中已经存在的接口，因此文档中保留说明，避免后续开发时忽略它。
- 后续如果加入独立的 `set_time_core`，更推荐的连接方式是 `set_time_core -> clock_core -> time_core`。
- 也就是说，`set_en / set_low / set_high` 现阶段更适合作为兼容保留接口，而不是后续所有新功能都直接依赖的统一接口。

### 1.5 后续新增文件的命名规则

后续新增功能请尽量按下面的名字新建文件：

- `src/set_time_core.v`
- `src/alarm_core.v`
- `src/countdown_core.v`

如果需要再拆辅助模块，推荐命名风格如下：

- `src/display_mux.v`
- `src/ring_mux.v`
- `src/alarm_compare.v`
- `src/countdown_counter.v`

命名建议：

- 文件名和模块名尽量一致
- 设时相关信号统一用 `set_` 前缀
- 闹钟相关信号统一用 `alarm_` 前缀
- 倒计时相关信号统一用 `countdown_` 或 `cd_` 前缀
- 普通走时相关信号统一用 `time_` 前缀

## 2. 设时功能

### 2.1 目标

设时功能的目的不是另外维护一套系统时间，而是：

- 让用户修改当前时间
- 修改完成后，把结果写回 `time_core`

也就是说，设时功能本质上是一个“编辑并提交”的模块，而不是新的时间源。

### 2.2 推荐文件

推荐新增文件：

- `src/set_time_core.v`

### 2.3 推荐职责

设时模块建议负责下面这些事：

- 在进入设时模式时，读取当前时间作为初始值
- 提供“选择当前编辑字段”的能力
- 支持修改秒、分、时
- 在用户确认后，将修改结果通过接口写回 `time_core`
- 在设时模式下向顶层提供显示内容

### 2.4 不建议做的事

设时模块不建议做下面这些事情：

- 不要直接改 `clock_core` 内部时间寄存器
- 不要自己长期维护一套主时间
- 不要在模块内部直接决定最终数码管显示输出

最终是否显示设时内容，应该由 `clock_core` 决定。

### 2.5 推荐接口

推荐接口如下：

```verilog
module set_time_core (
    input        clk,
    input        clr,
    input        set_mode_en,
    input        ui_select,
    input        ui_inc,
    input        ui_dec,
    input        ui_confirm,
    input  [3:0] set_low,
    input  [3:0] set_high,

    input  [3:0] cur_sec_low,
    input  [3:0] cur_sec_high,
    input  [3:0] cur_min_low,
    input  [3:0] cur_min_high,
    input  [3:0] cur_hour_low,
    input  [3:0] cur_hour_high,

    output       time_load_en,
    output [3:0] time_load_sec_low,
    output [3:0] time_load_sec_high,
    output [3:0] time_load_min_low,
    output [3:0] time_load_min_high,
    output [3:0] time_load_hour_low,
    output [3:0] time_load_hour_high,

    output [3:0] disp_sec_low,
    output [3:0] disp_sec_high,
    output [3:0] disp_min_low,
    output [3:0] disp_min_high,
    output [3:0] disp_hour_low,
    output [3:0] disp_hour_high
);
```

接口含义：

- `set_mode_en`：当前处于设时模式
- `ui_select`：切换当前编辑字段
- `ui_inc / ui_dec`：修改当前字段
- `ui_confirm`：确认并提交
- `set_low / set_high`：如果实验箱更适合拨码输入，可作为当前输入值
- `cur_*`：来自 `time_core` 的当前时间
- `time_load_*`：写回给 `time_core` 的时间值
- `disp_*`：设时模式下希望显示给用户的内容

### 2.6 与现有模块的关系

设时模块和现有模块的关系应该是：

- 从 `time_core` 读取当前时间
- 向 `time_core` 提交更新后的时间
- 如果当前版本仍保留 `set_en / set_low / set_high` 这组接口，建议由 `clock_core` 在内部完成适配
- 不直接接管 `second_counter` 和 `hour_counter`
- 最终显示由 `clock_core` 从设时显示输出和普通走时显示输出中做选择

## 3. 闹钟功能

### 3.1 目标

闹钟功能的目标是：

- 保存一组闹钟时间
- 支持闹钟启用和关闭
- 读取当前时间并与闹钟时间比较
- 到点后向顶层提出响铃请求

### 3.2 推荐文件

推荐新增文件：

- `src/alarm_core.v`

### 3.3 推荐职责

闹钟模块建议负责下面这些事：

- 保存闹钟时间
- 支持修改闹钟小时和分钟
- 保存闹钟总开关状态
- 根据 `time_core` 提供的当前时间判断是否到点
- 在到点时输出 `alarm_ring_req`
- 在闹钟模式下提供显示内容

### 3.4 不建议做的事

闹钟模块不建议做下面这些事情：

- 不要维护系统当前时间
- 不要直接修改 `time_core`
- 不要直接驱动最终蜂鸣器输出

闹钟模块只负责“判断是否该响”和“提出请求”，最终响铃仍由 `clock_core` 输出。

### 3.5 推荐接口

推荐接口如下：

```verilog
module alarm_core (
    input        clk,
    input        clr,
    input        tick,
    input        alarm_mode_en,
    input        alarm_enable_sw,
    input        ui_select,
    input        ui_inc,
    input        ui_dec,
    input        ui_confirm,
    input        ui_stop,
    input  [3:0] set_low,
    input  [3:0] set_high,

    input  [3:0] cur_min_low,
    input  [3:0] cur_min_high,
    input  [3:0] cur_hour_low,
    input  [3:0] cur_hour_high,

    output       alarm_match,
    output       alarm_ring_req,
    output [3:0] alarm_min_low,
    output [3:0] alarm_min_high,
    output [3:0] alarm_hour_low,
    output [3:0] alarm_hour_high,

    output [3:0] disp_sec_low,
    output [3:0] disp_sec_high,
    output [3:0] disp_min_low,
    output [3:0] disp_min_high,
    output [3:0] disp_hour_low,
    output [3:0] disp_hour_high
);
```

接口含义：

- `alarm_mode_en`：当前处于闹钟设置或查看模式
- `alarm_enable_sw`：闹钟总开关
- `ui_select`：切换当前编辑字段
- `ui_inc / ui_dec`：修改闹钟字段
- `ui_confirm`：确认闹钟设置
- `ui_stop`：停止当前闹钟响铃请求状态
- `cur_*`：来自 `time_core` 的当前时间
- `alarm_match`：当前时间与闹钟时间匹配
- `alarm_ring_req`：向顶层申请响铃
- `disp_*`：闹钟模式下的显示内容

### 3.6 与现有模块的关系

闹钟模块和现有模块的关系应该是：

- 只读取 `time_core` 当前时间
- 不修改 `time_core`
- 响铃请求输出到 `clock_core`
- 最终显示由 `clock_core` 统一选择

如果后续需要更清楚地拆开“闹钟时间比较”和“闹钟设置存储”，可以再增加一个辅助模块，比如：

- `src/alarm_compare.v`

## 4. 倒计时功能

### 4.1 目标

倒计时功能的目标是：

- 用户输入一个初始时间
- 启动后独立递减
- 支持暂停和停止
- 计时归零后向顶层提出响铃请求

倒计时功能是独立功能，不应复用普通时钟内部时间状态。

### 4.2 推荐文件

推荐新增文件：

- `src/countdown_core.v`

### 4.3 推荐职责

倒计时模块建议负责下面这些事：

- 保存倒计时初值
- 维护当前剩余时间
- 支持开始、暂停、停止
- 倒计时结束后输出 `countdown_timeout`
- 在需要时输出 `countdown_ring_req`
- 在倒计时相关模式下提供显示内容

### 4.4 不建议做的事

倒计时模块不建议做下面这些事情：

- 不要修改 `time_core` 中的当前时间
- 不要依赖普通走时内部寄存器
- 不要直接输出最终蜂鸣器信号

倒计时模块只需要负责自己的计时和到时请求。

### 4.5 推荐接口

推荐接口如下：

```verilog
module countdown_core (
    input        clk,
    input        clr,
    input        tick,
    input        countdown_mode_en,
    input        ui_select,
    input        ui_inc,
    input        ui_dec,
    input        ui_confirm,
    input        ui_start,
    input        ui_pause,
    input        ui_stop,
    input  [3:0] set_low,
    input  [3:0] set_high,

    output       countdown_running,
    output       countdown_timeout,
    output       countdown_ring_req,

    output [3:0] disp_sec_low,
    output [3:0] disp_sec_high,
    output [3:0] disp_min_low,
    output [3:0] disp_min_high,
    output [3:0] disp_hour_low,
    output [3:0] disp_hour_high
);
```

接口含义：

- `countdown_mode_en`：当前处于倒计时相关模式
- `ui_select`：切换当前编辑字段
- `ui_inc / ui_dec`：修改倒计时初值
- `ui_confirm`：确认倒计时初值
- `ui_start`：开始倒计时
- `ui_pause`：暂停倒计时
- `ui_stop`：停止倒计时并清除当前运行状态
- `countdown_running`：当前正在运行
- `countdown_timeout`：当前倒计时已经归零
- `countdown_ring_req`：向顶层申请响铃
- `disp_*`：倒计时模式下显示的剩余时间

### 4.6 与现有模块的关系

倒计时模块和现有模块的关系应该是：

- 独立于 `time_core`
- 不读取或修改系统主时间
- 到时后只向 `clock_core` 提交响铃请求
- 最终显示由 `clock_core` 统一选择

如果后续觉得需要把“编辑初值”和“运行计数”拆开，也可以继续新增辅助模块，例如：

- `src/countdown_counter.v`

## 5. 结论

- 普通走时归 `time_core`
- 顶层集成归 `clock_core`
- 设时、闹钟、倒计时分别新建独立核心文件
- 各功能只对 `clock_core` 提供接口，不彼此直接耦合
- 最终显示和响铃由 `clock_core` 统一仲裁

## 6. 功能关联图

```text
                           +------------------------+
                           |       clock_core       |
                           | 顶层接线 / 模式切换 /  |
                           | 显示选择 / 响铃仲裁    |
                           +-----+-----------+------+
                                 |           |
                                 |           +----------------------+
                                 |                                  |
                                 v                                  v
                           +-----------+                      +-------------+
                           | time_core |                      |  ring out   |
                           | 当前时间源 |                      | 最终响铃输出 |
                           +-----+-----+                      +-------------+
                                 ^
                                 |
                      time_load_* / 兼容 set_en
                                 |
                           +-----+------+
                           | set_time_  |
                           |   core     |
                           | 设时编辑模块 |
                           +------------+

                           +------------------------+
                           |       alarm_core       |
                           | 读取当前时间并比较闹钟 |
                           +-----------+------------+
                                       |
                               alarm_ring_req
                                       |
                                       v
                                  clock_core

                           +------------------------+
                           |    countdown_core      |
                           | 独立维护倒计时状态     |
                           +-----------+------------+
                                       |
                            countdown_ring_req
                                       |
                                       v
                                  clock_core
```

说明：

- `time_core` 是系统中的当前时间来源。
- `set_time_core` 负责编辑时间，并通过 `clock_core` 写回 `time_core`。
- `alarm_core` 读取当前时间并判断是否到达闹钟时刻，再向 `clock_core` 申请响铃。
- `countdown_core` 独立维护倒计时，不依赖 `time_core` 的内部状态，到时后向 `clock_core` 申请响铃。
- 最终显示输出和 `ring` 输出都由 `clock_core` 统一决定。
