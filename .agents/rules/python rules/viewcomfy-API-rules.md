---
trigger: glob
description: ViewComfy API 整合與 ComfyUI 工作流程開發準則，涵蓋 FastAPI 整合與 ComfyUI 工作流程執行
globs: ["**/viewcomfy/**/*.py", "**/*.py", "**/comfyui/**/*.py", "**/*viewcomfy*.py", "**/*comfy*.py", "**/workflow*.json"]
alwaysApply: false
---

# ViewComfy API 整合準則

> 參考通用 Python 規則：`python-core-rules.md`
> 參考 FastAPI 規則：`fastapi-python-cursor-rules.md`

你是一位精通 Python、FastAPI 整合和網頁應用程式開發的專家。你的任務是協助將 ViewComfy API 整合到使用 Python 的網頁應用程式中。

ViewComfy API 是一個使用 FastAPI 框架建構的無伺服器 API，可以執行自訂的 ComfyUI 工作流程。Python 版本使用 httpx 函式庫發出請求。

在實作 API 時，請記住第一次呼叫時可能會遇到冷啟動。此外，生成時間可能因工作流程而異；有些可能少於 2 秒，而有些可能需要幾分鐘。

呼叫 API 時，params 物件不能為空。如果沒有指定其他內容，請變更 seed 值。

API 回傳的資料格式如下：{ "prompt_id": "string", # 提示的唯一識別碼 "status": "string", # 當前執行狀態 "completed": bool, # 執行是否完成 "execution_time_seconds": float, # 執行所花費的時間 "prompt": dict, # 原始提示設定 "outputs": [ # 輸出檔案列表（可選） { "filename": "string", # 輸出檔案名稱 "content_type": "string", # 檔案的 MIME 型別 "data": "string", # Base64 編碼的檔案內容 "size": int # 檔案大小（位元組） }, # ... 可能有多個輸出檔案 ] }

ViewComfy 文件：

================================================

檔案：other_resources/guide_to_setting_up_and_using_ViewComfy_API.md

================================================

部署你的工作流程
你需要做的第一件事是使用 workflow_api.json 檔案在 ViewComfy 儀表板上部署你的 ComfyUI 工作流程。

使用 API 呼叫工作流程
ViewComfy API 是一個 REST API，可以使用標準 POST 請求呼叫，但也支援透過 Server-Sent Events 進行串流回應。第二個選項允許即時追蹤 ComfyUI 日誌。

取得你的 API 金鑰
為了使用你的 API 端點，你首先需要從 ViewComfy 儀表板建立你的 API 金鑰。

1.擷取你的工作流程參數

在設定請求之前，需要識別工作流程中的參數。這是透過使用範例 API 程式碼中的 ViewComfy_API/Python/workflow_parameters_maker.py 來扁平化你的 workflow_api.json。

扁平化的 json 檔案應該看起來像這樣：

{
"_3-node-class_type-info": "KSampler",
"3-inputs-cfg": 6,

…  

"_6-node-class_type-info": "CLIP Text Encode (Positive Prompt)",  
"6-inputs-clip": [  
    "38",  
    0  
],  
"6-inputs-text": "A woman raising her head with hair blowing in the wind",  

…  

"_52-node-class_type-info": "Load Image",  
"52-inputs-image": "<path_to_my_image>",  

…  
}

這個字典包含工作流程中的所有參數。每個參數的鍵包含 workflow_api.json 檔案中的節點 id、它是否是輸入，以及參數的輸入名稱。以「_」開頭的鍵只是為了提供對應 id 的節點上下文，它們不是參數。

在這個範例中，第一個鍵值對顯示節點 3 是 KSampler，而「3-inputs-cfg」設定其對應的 cfg 值。

2.使用你的參數更新腳本

首先要做的是從儀表板複製 ViewComfy 端點並將其設定為 view_comfy_api_url。你還應該取得之前建立的「Client ID」和「Client Secret」，並設定 client_id 和 client_secret 值：

view_comfy_api_url = "<Your_ViewComfy_endpoint>"
client_id = "<Your_ViewComfy_client_id>"
client_secret = "<Your_ViewComfy_client_secret>"

然後你可以使用上一步建立的 json 檔案中的鍵來設定參數。在這個範例中，我們將變更提示和輸入影像：

params = {}
params["6-inputs-text"] = "A flamingo dancing on top of a server in a pink universe, masterpiece, best quality, very aesthetic"
params["52-inputs-image"] = open("/home/gbieler/GitHub/API_tests/input_img.png", "rb")

3.呼叫 API

完成將參數新增到 ViewComfy_API/Python/main.py 後，你可以透過執行以下命令來呼叫 API：

python main.py

這會將你的參數發送到 ViewComfy_API/Python/api.py，其中儲存了所有呼叫 API 和處理輸出的函式。

預設情況下，腳本執行「infer_with_logs」函式，該函式透過串流回應回傳來自 ComfyUI 的生成日誌。如果你更願意透過標準 POST 請求呼叫 API，可以使用「infer」代替。

API 回傳的結果物件將包含工作流程輸出以及生成詳情。

你的輸出將自動儲存在你的工作目錄中。

================================================

檔案：ViewComfy_API/README.MD

================================================

## ViewComfy API 範例

## API

所有呼叫 API 和處理回應的函式都在 api 檔案（api.py）中。主檔案（main.py）接收特定於你的工作流程的參數，在大多數情況下，這將是你唯一需要編輯的檔案。

### API 檔案有兩個端點

- infer：經典的請求-回應端點，你等待請求完成後再取得結果。

- infer_with_logs：接收 ComfyUI 日誌的即時更新（例如進度條）。要使用此端點，你需要傳遞一個函式，該函式將在每次收到日誌訊息時被呼叫。

端點也可以將 workflow_api.json 作為參數。如果你想執行與部署時使用的工作流程不同的工作流程，這很有用。

### 取得你的 API 參數

要從你的 workflow_api.json 中擷取所有參數，你可以執行 workflow_api_parameter_creator 函式。這將建立一個包含工作流程中所有參數的字典。

```python

python workflow_parameters_maker.py --workflow_api_path "<Path to your workflow_api.json file>"

執行範例
安裝相依性：

pip install -r requirements.txt

新增你的端點並設定你的 API 金鑰：

將 main.py 內的 view_comfy_api_url 值變更為來自 ViewComfy 儀表板的 ViewComfy 端點。使用你的 API 金鑰對「client_id」和「client_secret」值執行相同操作（你也可以從儀表板取得它們）。如果你願意，可以同時在 main.py 中變更工作流程的參數。

呼叫 API：

python main.py

使用不同的工作流程使用 API
你可以在發送請求時覆寫預設的 workflow_api.json。如果你需要安裝新的節點套件來執行新工作流程，請小心。擁有太多自訂節點套件可能會在 Python 套件之間產生一些問題。這可能會增加 ComfyUI 啟動時間，在某些情況下會破壞 ComfyUI 安裝。

要使用更新的工作流程（與你的部署一起使用）與 API，你可以透過變更 override_workflow_api_path 值將新的 workflow_api.json 作為參數發送。例如，使用 python：

override_workflow_api_path = "<path_to_your_new_workflow_api_file>"
================================================ 檔案：ViewComfy_API/example_workflow/workflow_api(example).json
{ "3": { "inputs": { "seed": 268261030599666, "steps": 20, "cfg": 6, "sampler_name": "uni_pc", "scheduler": "simple", "denoise": 1, "model": [ "56", 0 ], "positive": [ "50", 0 ], "negative": [ "50", 1 ], "latent_image": [ "50", 2 ] }, "class_type": "KSampler", "_meta": { "title": "KSampler" } }, "6": { "inputs": { "text": "A flamingo dancing on top of a server in a pink universe, masterpiece, best quality, very aesthetic", "clip": [ "38", 0 ] }, "class_type": "CLIPTextEncode", "_meta": { "title": "CLIP Text Encode (Positive Prompt)" } }, "7": { "inputs": { "text": "Overexposure, static, blurred details, subtitles, paintings, pictures, still, overall gray, worst quality, low quality, JPEG compression residue, ugly, mutilated, redundant fingers, poorly painted hands, poorly painted faces, deformed, disfigured, deformed limbs, fused fingers, cluttered background, three legs, a lot of people in the background, upside down", "clip": [ "38", 0 ] }, "class_type": "CLIPTextEncode", "_meta": { "title": "CLIP Text Encode (Negative Prompt)" } },

...

"52": { "inputs": { "image": "SMT54Y6XHY1977QPBESY72WSR0.jpeg", "upload": "image" }, "class_type": "LoadImage", "_meta": { "title": "Load Image" } },

...

}

================================================ 檔案：ViewComfy_API/Python/api.py
import json from io import BufferedReader from typing import Any, Callable, Dict, List import httpx

class FileOutput: """表示一個檔案輸出，其內容以 base64 編碼"""

def __init__(self, filename: str, content_type: str, data: str, size: int):
    """
    初始化 FileOutput 物件。

    參數：
        filename (str): 輸出檔案名稱
        content_type (str): 檔案的 MIME 型別
        data (str): Base64 編碼的檔案內容
        size (int): 檔案大小（位元組）
    """
    self.filename = filename
    self.content_type = content_type
    self.data = data
    self.size = size
class PromptResult: def init( self, prompt_id: str, status: str, completed: bool, execution_time_seconds: float, prompt: Dict, outputs: List[Dict] | None = None, ): """ 初始化 PromptResult 物件。

    參數：
        prompt_id (str): 提示的唯一識別碼
        status (str): 提示執行的當前狀態
        completed (bool): 提示執行是否完成
        execution_time_seconds (float): 執行提示所花費的時間
        prompt (Dict): 原始提示設定
        outputs (List[Dict], 可選): 輸出檔案資料列表。預設為空列表。
    """
    self.prompt_id = prompt_id
    self.status = status
    self.completed = completed
    self.execution_time_seconds = execution_time_seconds
    self.prompt = prompt

    # 將輸出初始化為 FileOutput 物件
    self.outputs = []
    if outputs:
        for output_data in outputs:
            self.outputs.append(
                FileOutput(
                    filename=output_data.get("filename", ""),
                    content_type=output_data.get("content_type", ""),
                    data=output_data.get("data", ""),
                    size=output_data.get("size", 0),
                )
            )
class ComfyAPIClient: def init( self, *, infer_url: str | None = None, client_id: str | None = None, client_secret: str | None = None, ): """ 使用伺服器 URL 初始化 ComfyAPI 客戶端。

    參數：
        base_url (str): API 伺服器的基礎 URL
    """
    if infer_url is None:
        raise Exception("infer_url is required")
    self.infer_url = infer_url

    if client_id is None:
        raise Exception("client_id is required")

    if client_secret is None:
        raise Exception("client_secret is required")

    self.client_id = client_id
    self.client_secret = client_secret

async def infer(
    self,
    *,
    data: Dict[str, Any],
    files: list[tuple[str, BufferedReader]] = [],
) -> Dict[str, Any]:
    """
    向 /api/infer-files 端點發出 POST 請求，檔案以表單資料編碼。

    參數：
        data: 表單欄位字典（logs、params 等）
        files: 將檔案鍵對應到 (filename, content, content_type) 元組的字典
               範例：{"composition_image": ("image.jpg", file_content, "image/jpeg")}

    回傳：
        Dict[str, Any]: 來自伺服器的回應
    """

    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(
                self.infer_url,
                data=data,
                files=files,
                timeout=httpx.Timeout(2400.0),
                follow_redirects=True,
                headers={
                    "client_id": self.client_id,
                    "client_secret": self.client_secret,
                },
            )

            if response.status_code == 201:
                return response.json()
            else:
                error_text = response.text
                raise Exception(
                    f"API request failed with status {response.status_code}: {error_text}"
                )
        except httpx.HTTPError as e:
            raise Exception(f"Connection error: {str(e)}")
        except Exception as e:
            raise Exception(f"Error during API call: {str(e)}")

async def consume_event_source(
    self, *, response, logging_callback: Callable[[str], None]
) -> Dict[str, Any] | None:
    """
    處理串流 Server-Sent Events (SSE) 回應。

    參數：
        response: 一個活動的 httpx 串流回應物件

    回傳：
        已解析的事件物件列表
    """
    current_data = ""
    current_event = "message"  # 預設事件型別

    prompt_result = None
    # 處理串流中的回應
    async for line in response.aiter_lines():
        line = line.strip()
        if prompt_result:
            break
        # 空行表示事件的結束
        if not line:
            if current_data:
                try:
                    if current_event in ["log_message", "error"]:
                        logging_callback(f"{current_event}: {current_data}")
                    elif current_event == "prompt_result":
                        prompt_result = json.loads(current_data)
                    else:
                        print(
                            f"Unknown event: {current_event}, data: {current_data}"
                        )
                except json.JSONDecodeError as e:
                    print("Invalid JSON: ...")
                    print(e)
                # 為下一個事件重置
                current_data = ""
                current_event = "message"
            continue

        # 解析 SSE 欄位
        if line.startswith("event:"):
            current_event = line[6:].strip()
        elif line.startswith("data:"):
            current_data = line[5:].strip()
        elif line.startswith("id:"):
            # 如果需要，處理事件 ID
            pass
        elif line.startswith("retry:"):
            # 如果需要，處理重試指令
            pass
    return prompt_result

async def infer_with_logs(
    self,
    *,
    data: Dict[str, Any],
    logging_callback: Callable[[str], None],
    files: list[tuple[str, BufferedReader]] = [],
) -> Dict[str, Any] | None:
    if data.get("logs") is not True:
        raise Exception("Set the logs to True for streaming the process logs")

    async with httpx.AsyncClient() as client:
        try:
            async with client.stream(
                "POST",
                self.infer_url,
                data=data,
                files=files,
                timeout=24000,
                follow_redirects=True,
                headers={
                    "client_id": self.client_id,
                    "client_secret": self.client_secret,
                },
            ) as response:
                if response.status_code == 201:
                    # 檢查它是否實際上是 server-sent event 串流
                    if "text/event-stream" in response.headers.get(
                        "content-type", ""
                    ):
                        prompt_result = await self.consume_event_source(
                            response=response, logging_callback=logging_callback
                        )
                        return prompt_result
                    else:
                        # 對於非 SSE 回應，正常讀取內容
                        raise Exception(
                            "Set the logs to True for streaming the process logs"
                        )
                else:
                    error_response = await response.aread()
                    error_data = json.loads(error_response)
                    raise Exception(
                        f"API request failed with status {response.status_code}: {error_data}"
                    )
        except Exception as e:
            raise Exception(f"Error with streaming request: {str(e)}")
def parse_parameters(params: dict): """ 將參數從字典解析為適合 API 呼叫的格式。

參數：
    params (dict): 參數字典

回傳：
    dict: 已解析的參數
"""
parsed_params = {}
files = []
for key, value in params.items():
    if isinstance(value, BufferedReader):
        files.append((key, value))
    else:
        parsed_params[key] = value
return parsed_params, files
async def infer( *, params: Dict[str, Any], api_url: str, override_workflow_api: Dict[str, Any] | None = None, client_id: str, client_secret: str, ): """ 使用執行提示的即時日誌進行推理

參數：
    api_url (str): 發送請求的 URL
    params (dict): 發送到工作流程的參數
    override_workflow_api (dict): 可選覆寫部署的預設 workflow_api

回傳：
    PromptResult: 包含輸出和執行詳情的推理結果
"""
client = ComfyAPIClient(
    infer_url=api_url,
    client_id=client_id,
    client_secret=client_secret,
)

params_parsed, files = parse_parameters(params)
data = {
    "logs": False,
    "params": json.dumps(params_parsed),
    "workflow_api": json.dumps(override_workflow_api)
    if override_workflow_api
    else None,
}

# 進行 API 呼叫
result = await client.infer(data=data, files=files)

return PromptResult(**result)
async def infer_with_logs( *, params: Dict[str, Any], logging_callback: Callable[[str], None], api_url: str, override_workflow_api: Dict[str, Any] | None = None, client_id: str, client_secret: str, ): """ 使用執行提示的即時日誌進行推理

參數：
    api_url (str): 發送請求的 URL
    params (dict): 發送到工作流程的參數
    override_workflow_api (dict): 可選覆寫部署的預設 workflow_api
    logging_callback (Callable[[str], None]): 處理日誌訊息的回呼函式

回傳：
    PromptResult: 包含輸出和執行詳情的推理結果
"""

client = ComfyAPIClient(
    infer_url=api_url,
    client_id=client_id,
    client_secret=client_secret,
)

params_parsed, files = parse_parameters(params)
data = {
    "logs": True,
    "params": json.dumps(params_parsed),
    "workflow_api": json.dumps(override_workflow_api)
    if override_workflow_api
    else None,
}

# 進行 API 呼叫
result = await client.infer_with_logs(
    data=data,
    files=files,
    logging_callback=logging_callback,
)

if result:
    return PromptResult(**result)
```

檔案：ViewComfy_API/Python/main.py

```python
import asyncio import base64 import json import os from api import infer, infer_with_logs

async def api_examples():

view_comfy_api_url = "<Your_ViewComfy_endpoint>"
client_id = "<Your_ViewComfy_client_id>"
client_secret = "<Your_ViewComfy_client_secret>"

override_workflow_api_path = None # 進階功能：使用新工作流程覆寫預設工作流程

# 設定參數
params = {}

params["6-inputs-text"] = "A cat sorcerer"
params["52-inputs-image"] = open("input_folder/input_img.png", "rb")

override_workflow_api = None
if  override_workflow_api_path:
    if os.path.exists(override_workflow_api_path):  
        with open(override_workflow_api_path, "r") as f:
            override_workflow_api = json.load(f)
    else:
        print(f"Error: {override_workflow_api_path} does not exist")

def logging_callback(log_message: str):
    print(log_message)

# 呼叫 API 並等待結果
# try:
#     prompt_result = await infer(
#         api_url=view_comfy_api_url,
#         params=params,
#         client_id=client_id,
#         client_secret=client_secret,
#     )
# except Exception as e:
#     print("something went wrong calling the api")
#     print(f"Error: {e}")
#     return

# 呼叫 API 並即時取得執行的日誌
# 你可以使用任何你想要的函式
try:
    prompt_result = await infer_with_logs(
        api_url=view_comfy_api_url,
        params=params,
        logging_callback=logging_callback,
        client_id=client_id,
        client_secret=client_secret,
        override_workflow_api=override_workflow_api,
    )
except Exception as e:
    print("something went wrong calling the api")
    print(f"Error: {e}")
    return

if not prompt_result:
    print("No prompt_result generated")
    return

for file in prompt_result.outputs:
    try:
        # 在寫入檔案之前解碼 base64 資料
        binary_data = base64.b64decode(file.data)
        with open(file.filename, "wb") as f:
            f.write(binary_data)
        print(f"Successfully saved {file.filename}")
    except Exception as e:
        print(f"Error saving {file.filename}: {str(e)}")
if name == "main": asyncio.run(api_examples())
```

================================================
檔案：ViewComfy_API/Python/requirements.txt

```text
httpx==0.28.1
```

================================================
檔案：ViewComfy_API/Python/workflow_api_parameter_creator.py

```python
from typing import Dict, Any

def workflow_api_parameters_creator(workflow: Dict[str, Dict[str, Any]]) -> Dict[str, Any]: """ 將工作流程 API JSON 結構扁平化為簡單的鍵值物件

參數：
    workflow: 工作流程 API JSON 物件

回傳：
    一個扁平化物件，鍵的格式為 "nodeId-inputs-paramName" 或 "nodeId-class_type-info"
"""
flattened: Dict[str, Any] = {}

# 迭代工作流程中的每個節點
for node_id, node in workflow.items():
    # 新增 class_type-info 鍵，優先使用 _meta.title（如果可用）
    class_type_info = node.get("_meta", {}).get("title") or node.get("class_type")
    flattened[f"_{node_id}-node-class_type-info"] = class_type_info
    
    # 處理所有輸入
    if "inputs" in node:
        for input_key, input_value in node["inputs"].items():
            flattened[f"{node_id}-inputs-{input_key}"] = input_value

return flattened
""" 範例用法：

import json

with open('workflow_api.json', 'r') as f: workflow_json = json.load(f)

flattened = create_workflow_api_parameters(workflow_json) print(flattened) """
```

================================================
檔案：ViewComfy_API/Python/workflow_parameters_maker.py

```python
import json from workflow_api_parameter_creator import workflow_api_parameters_creator import argparse

parser = argparse.ArgumentParser(description='Process workflow API parameters') parser.add_argument('--workflow_api_path', type=str, required=True, help='Path to the workflow API JSON file')

解析參數
args = parser.parse_args()

with open(args.workflow_api_path, 'r') as f: workflow_json = json.load(f)

parameters = workflow_api_parameters_creator(workflow_json)

with open('workflow_api_parameters.json', 'w') as f: json.dump(parameters, f, indent=4)
```
