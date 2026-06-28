--!strict
-- RuntimeManager.lua
--
-- Central runtime controller.
-- Responsible for:
--  - lifecycle management
--  - ownership
--  - startup/shutdown flow
--  - connecting all runtime subsystems
--
-- Other systems (ResourceManager, Scheduler, ModuleLoader, etc.)
-- will be attached in later pieces.


local RuntimeManager = {}
RuntimeManager.__index = RuntimeManager


local ResourceManager =
	require(script.ResourceManager)

local Logger =
	require(script.Logger)

local ErrorHandler =
	require(script.ErrorHandler)

local Scheduler =
	require(script.Scheduler)

local Environment =
	require(script.Environment)

local ModuleLoader =
	require(script.ModuleLoader)

local ServiceContainer =
	require(script.ServiceContainer)

local InstanceManager =
	require(script.InstanceManager)

local ConnectionManager =
	require(script.ConnectionManager)

local ConfigManager =
	require(script.ConfigManager)

local Profiler =
	require(script.Profiler)


export type RuntimeState =
	"Created"
	| "Initializing"
	| "Loading"
	| "Running"
	| "Paused"
	| "Stopping"
	| "Destroyed"



export type RuntimeConfig = {

	Debug: boolean?,
	AutoCleanup: boolean?,
	LoggingLevel: string?,

}



function RuntimeManager.new(
	name: string?,
	config: RuntimeConfig?
)

	local self = setmetatable({}, RuntimeManager)

self.Name =
		name or "Runtime"


	self.Config =
		ConfigManager.new(config)



	self.State =
		"Created"



	-- Sistemler

	self.Logger =
		Logger.new(self)


	self.Errors =
		ErrorHandler.new(self)


	self.Resources =
		ResourceManager.new(self)


	self.Scheduler =
		Scheduler.new(self)


	self.Environment =
		Environment.new(self)


	self.Modules =
		ModuleLoader.new(self)


	self.Services =
		ServiceContainer.new(self)


	self.Instances =
		InstanceManager.new(self)


	self.Connections =
		ConnectionManager.new(self)


	self.Profiler =
		Profiler.new(self)



	self._destroyed = false
	
	return self
end
	
------------------------------------------------
	-- Identity
	------------------------------------------------

	self.Name = name or "Runtime"

	
	self.Config =
	ConfigManager.new(config)

		Debug = false,
		AutoCleanup = true,
		LoggingLevel = "INFO"

	}



	------------------------------------------------
	-- Lifecycle state
	------------------------------------------------

	self.State = "Created"



	------------------------------------------------
	-- Internal storage
	------------------------------------------------

	self.StartTime = os.clock()


	-- Placeholder containers.
	-- Later pieces will replace these
	-- with actual managers.

	local ResourceManager =
	require(script.ResourceManager)


local Logger =
	require(script.Logger)


local ErrorHandler =
	require(script.ErrorHandler)



self.Resources =
	ResourceManager.new(self)



self.Logger =
	Logger.new(self)



self.Errors =
	ErrorHandler.new(self)



self.Modules =
	ModuleLoader.new(self)

self.Services =
	ServiceContainer.new(self)
	
	self.Instances =
	InstanceManager.new(self)

local Scheduler =
	require(script.Scheduler)


-- Sistemler

self.Resources =
	ResourceManager.new(self)


self.Logger =
	Logger.new(self)


self.Errors =
	ErrorHandler.new(self)


self.Scheduler =
	Scheduler.new(self)


self.Environment =
	Environment.new(self)


self.Connections =
	ConnectionManager.new(self)
	
	self.Profiler =
	Profiler.new(self)
	
	------------------------------------------------
	-- Runtime flags
	------------------------------------------------

	self._destroyed = false


	return self

end





------------------------------------------------
-- Lifecycle
------------------------------------------------


function RuntimeManager:Init()

	if self.State ~= "Created" then
		warn(
			self.Name,
			"already initialized"
		)

		return
	end



	self.State = "Initializing"



	self:_log(
		"Initializing runtime"
	)



	--
	-- Future:
	-- ResourceManager.Init()
	-- ModuleLoader.Init()
	-- ServiceContainer.Init()
	--

self.Services:StartAll()
	self.State = "Loading"


	self:_log(
		"Runtime ready for loading"
	)

end





function RuntimeManager:Start()

	if self._destroyed then
		return
	end


	if self.State ~= "Loading"
	and self.State ~= "Paused" then

		warn(
			self.Name,
			"cannot start from",
			self.State
		)

		return
	end



	self.State = "Running"
	self.Scheduler:Start()



	self:_log(
		"Runtime started"
	)

end





function RuntimeManager:Pause()

	if self.State ~= "Running" then
		return
	end



	self.State = "Paused"



	self:_log(
		"Runtime paused"
	)

end





function RuntimeManager:Restart()

	if self._destroyed then
		return
	end



	self:_log(
		"Restarting runtime"
	)



	self:Cleanup()



	self._destroyed = false


	self.State = "Created"


	self:Init()

end





------------------------------------------------
-- Cleanup
------------------------------------------------


function RuntimeManager:Cleanup()

	if self._destroyed then
		return
	end



	self.State = "Stopping"



	self:_log(
		"Cleaning runtime"
	)

self.Scheduler:Destroy()

self.Modules:Destroy()

self.Services:Destroy()

self.Instances:Destroy()

self.Connections:Destroy()

self.Profiler:Destroy()

	------------------------------------------------
	-- Future:
	--
	-- Destroy resources
	-- Stop services
	-- Cancel tasks
	-- Clear modules
	------------------------------------------------



	table.clear(self.Resources)
	table.clear(self.Modules)
	table.clear(self.Services)
	table.clear(self.Tasks)



	self.State = "Destroyed"

	self._destroyed = true



	self:_log(
		"Runtime destroyed"
	)

end





------------------------------------------------
-- Utilities
------------------------------------------------


function RuntimeManager:IsRunning()

	return self.State == "Running"

end





function RuntimeManager:GetState()

	return self.State

end





function RuntimeManager:_log(message)

	if self.Config.Debug then

		print(
			"[Runtime:",
			self.Name .. "]",
			message
		)

	end

end





return RuntimeManager

--!strict
-- ResourceManager.lua
--
-- Tracks everything owned by a runtime:
--  - Instances
--  - RBXScriptConnections
--  - tasks
--  - coroutines
--  - custom objects
--
-- Provides:
--  - ownership
--  - cleanup
--  - leak prevention


local ResourceManager = {}
ResourceManager.__index = ResourceManager



export type ResourceRecord = {

	Type: string,

	Object: any,

	Destroy: (() -> ())?

}




function ResourceManager.new(runtime)

	local self = setmetatable({}, ResourceManager)


	self.Runtime = runtime


	-- weak keys prevent accidental memory retention
	self.Resources = setmetatable(
		{},
		{
			__mode = "k"
		}
	)


	self.Count = 0


	return self

end





------------------------------------------------
-- Generic registration
------------------------------------------------


function ResourceManager:Register(
	object,
	destroyer?,
	resourceType?
)

	if object == nil then
		return nil
	end



	local record: ResourceRecord = {

		Type =
			resourceType
			or typeof(object),

		Object = object,

		Destroy = destroyer

	}



	self.Resources[object] = record


	self.Count += 1



	return object

end





------------------------------------------------
-- Instance tracking
------------------------------------------------


function ResourceManager:RegisterInstance(instance)

	assert(
		typeof(instance) == "Instance",
		"Expected Instance"
	)



	return self:Register(

		instance,

		function()

			if instance.Parent then
				instance:Destroy()
			end

		end,

		"Instance"

	)

end





------------------------------------------------
-- Connection tracking
------------------------------------------------


function ResourceManager:RegisterConnection(connection)

	assert(
		connection.Connected ~= nil,
		"Expected RBXScriptConnection"
	)



	return self:Register(

		connection,

		function()

			if connection.Connected then
				connection:Disconnect()
			end

		end,

		"Connection"

	)

end





------------------------------------------------
-- Task tracking
------------------------------------------------


function ResourceManager:RegisterTask(thread)

	return self:Register(

		thread,

		function()

			if task.cancel then

				pcall(
					task.cancel,
					thread
				)

			end

		end,

		"Task"

	)

end





------------------------------------------------
-- Coroutine tracking
------------------------------------------------


function ResourceManager:RegisterCoroutine(thread)

	return self:Register(

		thread,

		function()

			if coroutine.status(thread)
			~= "dead" then

				-- cannot kill a coroutine
				-- safely; allow it to exit

			end

		end,

		"Coroutine"

	)

end





------------------------------------------------
-- Remove one resource
------------------------------------------------


function ResourceManager:Remove(object)

	local record =
		self.Resources[object]


	if not record then
		return
	end



	if record.Destroy then

		pcall(
			record.Destroy
		)

	end



	self.Resources[object] = nil


	self.Count -= 1

end





------------------------------------------------
-- Destroy everything
------------------------------------------------


function ResourceManager:DestroyAll()

	local destroyed = 0



	for object, record in pairs(self.Resources) do


		pcall(function()


			if record.Destroy then

				record.Destroy()

			elseif typeof(object)
				== "Instance" then

				object:Destroy()

			end


		end)



		self.Resources[object] = nil


		destroyed += 1


	end



	self.Count = 0



	return destroyed

end





------------------------------------------------
-- Debug helpers
------------------------------------------------


function ResourceManager:GetCount()

	return self.Count

end





function ResourceManager:GetSnapshot()

	local result = {}


	for _,record in pairs(self.Resources) do

		table.insert(
			result,
			record
		)

	end


	return result

end





return ResourceManager

--!strict
-- Logger.lua
--
-- Runtime log sistemi.
--
-- Özellikler:
--  - DEBUG
--  - INFO
--  - WARNING
--  - ERROR
--  - Saat bilgisi
--  - Runtime adı
--  - Log seviyesi filtreleme


local Logger = {}
Logger.__index = Logger



local Levels = {

	DEBUG = 1,
	INFO = 2,
	WARNING = 3,
	ERROR = 4

}





function Logger.new(runtime)

	local self = setmetatable({}, Logger)


	self.Runtime = runtime


	-- Config üzerinden log seviyesi alır

	self.Level =
		Levels[
			runtime.Config.LoggingLevel
			or "INFO"
		]
		or Levels.INFO



	return self

end





------------------------------------------------
-- Log formatlama
------------------------------------------------


function Logger:_format(
	level,
	message
)

	return string.format(

		"[%s] [%s] [%s] %s",

		os.date("%H:%M:%S"),

		self.Runtime.Name,

		level,

		message

	)

end





------------------------------------------------
-- Ana log fonksiyonu
------------------------------------------------


function Logger:Log(
	level,
	message
)


	if Levels[level] < self.Level then
		return
	end



	print(

		self:_format(
			level,
			message
		)

	)

end





function Logger:Debug(message)

	self:Log(
		"DEBUG",
		message
	)

end



function Logger:Info(message)

	self:Log(
		"INFO",
		message
	)

end



function Logger:Warning(message)

	self:Log(
		"WARNING",
		message
	)

end



function Logger:Error(message)

	self:Log(
		"ERROR",
		message
	)

end





return Logger

--!strict
-- ErrorHandler.lua
--
-- Runtime hata yönetimi.
--
-- Amaç:
-- Bir sistem hata verdiğinde
-- tüm runtime kapanmasın.


local ErrorHandler = {}
ErrorHandler.__index = ErrorHandler





function ErrorHandler.new(runtime)

	local self = setmetatable({}, ErrorHandler)


	self.Runtime = runtime


	-- geçmiş hatalar

	self.Errors = {}


	return self

end





------------------------------------------------
-- Hata kaydetme
------------------------------------------------


function ErrorHandler:Report(data)


	local errorData = {


		Runtime =
			self.Runtime.Name,


		State =
			self.Runtime.State,


		Category =
			data.Category
			or "Runtime",


		Module =
			data.Module
			or "Unknown",


		Message =
			data.Error
			or "Unknown error",


		Time =
			os.time(),


		Stack =
			debug.traceback()

	}





	table.insert(
		self.Errors,
		errorData
	)





	-- Log sistemine gönder

	self.Runtime.Logger:Error(

		string.format(

			"%s | %s | %s",

			errorData.Category,

			errorData.Module,

			errorData.Message

		)

	)



	return errorData

end





------------------------------------------------
-- Güvenli fonksiyon çalıştırma
------------------------------------------------
--
-- Hata olursa runtime çökmez.


function ErrorHandler:SafeCall(
	name,
	callback,
	...

)


	local args =
		table.pack(...)



	local success, result =
		pcall(function()


			return callback(

				table.unpack(
					args,
					1,
					args.n
				)

			)


		end)




	if not success then


		self:Report({

			Category =
				"Execution",


			Module =
				name,


			Error =
				result

		})


		return nil

	end



	return result

end





function ErrorHandler:GetErrors()

	return self.Errors

end





return ErrorHandler

--!strict
-- Scheduler.lua
--
-- Runtime görev yöneticisi.
--
-- Özellikler:
--  - Öncelikli görev kuyruğu
--  - Deferred execution
--  - Güvenli task çalıştırma
--  - Runtime kapanınca otomatik durma


local Scheduler = {}
Scheduler.__index = Scheduler



export type TaskData = {

	Id: number,

	Callback: () -> (),

	Priority: number,

	State: string

}





function Scheduler.new(runtime)


	local self = setmetatable({}, Scheduler)


	self.Runtime = runtime


	self.Queue = {}


	self.NextId = 0


	self.Running = false


	self.Thread = nil



	return self

end





------------------------------------------------
-- Task ekleme
------------------------------------------------


function Scheduler:Add(
	callback,
	priority
)

	assert(
		type(callback) == "function",
		"Scheduler callback function olmalı"
	)



	self.NextId += 1



	local taskData: TaskData = {


		Id =
			self.NextId,


		Callback =
			callback,


		Priority =
			priority or 0,


		State =
			"Queued"

	}




	table.insert(
		self.Queue,
		taskData
	)



	return taskData.Id

end





------------------------------------------------
-- Gecikmeli task
------------------------------------------------


function Scheduler:Defer(
	callback,
	delayTime,
	priority
)


	local thread = task.delay(

		delayTime or 0,

		function()


			self:Add(
				callback,
				priority
			)


		end

	)



	return thread

end





------------------------------------------------
-- Kuyruk sıralama
------------------------------------------------


function Scheduler:_SortQueue()


	table.sort(

		self.Queue,

		function(a,b)


			return a.Priority
				>
				b.Priority


		end

	)

end





------------------------------------------------
-- Task çalıştırma
------------------------------------------------


function Scheduler:_Execute(taskData)


	taskData.State =
		"Running"



	local success, errorMessage =
		pcall(

			taskData.Callback

		)




	if not success then


		self.Runtime.Errors:Report({

			Category =
				"Scheduler",


			Module =
				"Task:"
				.. taskData.Id,


			Error =
				errorMessage

		})

	end




	taskData.State =
		"Finished"

end





------------------------------------------------
-- Scheduler başlat
------------------------------------------------


function Scheduler:Start()


	if self.Running then
		return
	end



	self.Running = true



	self.Runtime.Logger:Info(
		"Scheduler başladı"
	)





	self.Thread =
		task.spawn(function()



			while self.Running do



				self:_SortQueue()



				local nextTask =
					table.remove(
						self.Queue,
						1
					)




				if nextTask then


					self:_Execute(
						nextTask
					)


				end





				task.wait()

			end



		end)


end





------------------------------------------------
-- Durdurma
------------------------------------------------


function Scheduler:Stop()


	self.Running = false



	self.Queue = {}



	self.Runtime.Logger:Warning(
		"Scheduler durdu"
	)


end





------------------------------------------------
-- Cleanup
------------------------------------------------


function Scheduler:Destroy()

	self:Stop()


	self.Thread = nil


end





function Scheduler:GetQueueSize()

	return #self.Queue

end





return Scheduler

--!strict
-- Environment.lua
--
-- Module çalışma ortamı yöneticisi.
--
-- Her module için:
--  - ayrı context
--  - private state
--  - runtime erişimi
--  - servis erişimi
--
-- sağlar.


local Environment = {}
Environment.__index = Environment





function Environment.new(runtime)

	local self = setmetatable({}, Environment)


	self.Runtime = runtime


	-- Module contextleri

	self.Contexts = {}



	return self

end





------------------------------------------------
-- Yeni module context oluşturur
------------------------------------------------


function Environment:Create(
	moduleName: string
)


	assert(
		moduleName,
		"Module adı gerekli"
	)



	-- Aynı module tekrar oluşturulmaz

	if self.Contexts[moduleName] then

		return self.Contexts[moduleName]

	end





	local context = {


		Name =
			moduleName,



		Runtime =
			self.Runtime,



		------------------------------------------------
		-- Ortak sistemler
		------------------------------------------------

		Logger =
			self.Runtime.Logger,


		Errors =
			self.Runtime.Errors,


		Scheduler =
			self.Runtime.Scheduler,


		Resources =
			self.Runtime.Resources,



		Services =
			self.Runtime.Services,



		Config =
			self.Runtime.Config,



		------------------------------------------------
		-- Module özel alanı
		------------------------------------------------

		State = {},



		Created =
			os.clock()

	}






	self.Contexts[moduleName] =
		context





	return context

end





------------------------------------------------
-- Context al
------------------------------------------------


function Environment:Get(
	moduleName: string
)


	return self.Contexts[moduleName]

end





------------------------------------------------
-- Module context sil
------------------------------------------------


function Environment:Destroy(
	moduleName: string
)


	local context =
		self.Contexts[moduleName]



	if not context then
		return
	end



	table.clear(
		context.State
	)



	self.Contexts[moduleName] = nil


end





------------------------------------------------
-- Hepsini temizle
------------------------------------------------


function Environment:DestroyAll()


	for name in pairs(
		self.Contexts
	) do


		self:Destroy(name)


	end


end





return Environment

--!strict
-- ModuleLoader.lua
--
-- Runtime Module sistemi.
--
-- Yönetir:
--  - require cache
--  - module durumları
--  - dependency kontrolü
--  - circular dependency
--  - güvenli yükleme


local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader



export type ModuleState =
	"Unloaded"
	| "Loading"
	| "Loaded"
	| "Failed"





function ModuleLoader.new(runtime)

	local self = setmetatable({}, ModuleLoader)


	self.Runtime = runtime



	------------------------------------------------
	-- Cache
	------------------------------------------------

	self.Cache = {}



	------------------------------------------------
	-- Module durumları
	------------------------------------------------

	self.States = {}



	------------------------------------------------
	-- Dependency graph
	------------------------------------------------

	self.Dependencies = {}



	------------------------------------------------
	-- Loading stack
	-- circular dependency için
	------------------------------------------------

	self.LoadingStack = {}



	return self

end





------------------------------------------------
-- Module yükleme
------------------------------------------------


function ModuleLoader:Load(
	moduleScript
)

	assert(
		moduleScript:IsA("ModuleScript"),
		"ModuleScript gerekli"
	)



	------------------------------------------------
	-- Cache kontrol
	------------------------------------------------

	if self.Cache[moduleScript] then

		return self.Cache[moduleScript]

	end





	------------------------------------------------
	-- Circular dependency kontrolü
	------------------------------------------------


	if self.States[moduleScript]
		== "Loading" then



		error(

			"Circular dependency detected: "
			.. moduleScript.Name

		)

	end





	self.States[moduleScript] =
		"Loading"



	table.insert(
		self.LoadingStack,
		moduleScript
	)






	local success, result =
		pcall(function()


			return require(
				moduleScript
			)


		end)






	table.remove(
		self.LoadingStack
	)





	if not success then


		self.States[moduleScript] =
			"Failed"



		self.Runtime.Errors:Report({

			Category =
				"Module",


			Module =
				moduleScript.Name,


			Error =
				result

		})



		return nil

	end





	------------------------------------------------
	-- Cache kaydı
	------------------------------------------------


	self.Cache[moduleScript] =
		result



	self.States[moduleScript] =
		"Loaded"






	------------------------------------------------
	-- Module Init
	------------------------------------------------


	if type(result) == "table"
	and result.Init then



		local context =
			self.Runtime.Environment:Create(

				moduleScript.Name

			)




		self.Runtime.Errors:SafeCall(

			moduleScript.Name,

			function()


				result.Init(
					context
				)


			end

		)


	end






	return result

end







------------------------------------------------
-- Klasörden module yükleme
------------------------------------------------


function ModuleLoader:LoadFolder(
	folder
)

	local loaded = {}




	for _,object in ipairs(
		folder:GetDescendants()
	) do



		if object:IsA("ModuleScript") then



			local module =
				self:Load(object)




			loaded[object.Name] =
				module



		end



	end





	return loaded

end







------------------------------------------------
-- Durum bilgisi
------------------------------------------------


function ModuleLoader:GetState(
	moduleScript
)

	return self.States[moduleScript]
	or "Unloaded"

end





------------------------------------------------
-- Temizlik
------------------------------------------------


function ModuleLoader:Destroy()


	table.clear(
		self.Cache
	)


	table.clear(
		self.States
	)


	table.clear(
		self.Dependencies
	)


	table.clear(
		self.LoadingStack
	)


end





return ModuleLoader

--!strict
-- ServiceContainer.lua
--
-- Runtime servis yöneticisi.
--
-- Sağlar:
--  - Servis kaydı
--  - Servis erişimi
--  - Lifecycle yönetimi
--  - Cleanup


local ServiceContainer = {}
ServiceContainer.__index = ServiceContainer





export type Service = {

	Start: ((runtime) -> ())?,

	Stop: (() -> ())?,

	Cleanup: (() -> ())?

}







function ServiceContainer.new(runtime)


	local self = setmetatable({}, ServiceContainer)


	self.Runtime = runtime


	self.Services = {}

	self.Started = {}



	return self

end







------------------------------------------------
-- Servis kaydetme
------------------------------------------------


function ServiceContainer:Register(
	name: string,
	service: Service
)


	assert(
		type(name) == "string",
		"Service adı string olmalı"
	)



	assert(
		type(service) == "table",
		"Service table olmalı"
	)





	if self.Services[name] then


		warn(
			"Service zaten kayıtlı:",
			name
		)


		return

	end






	self.Services[name] =
		service






	self.Runtime.Logger:Info(

		"Service registered: "
		.. name

	)





end







------------------------------------------------
-- Servis başlatma
------------------------------------------------


function ServiceContainer:StartAll()


	for name, service in pairs(
		self.Services
	) do



		if service.Start then



			local success, err =
				pcall(function()


					service.Start(
						self.Runtime
					)



				end)





			if not success then


				self.Runtime.Errors:Report({

					Category =
						"Service",


					Module =
						name,


					Error =
						err

				})



			else


				self.Started[name] =
					true



			end


		end


	end



end







------------------------------------------------
-- Servis alma
------------------------------------------------


function ServiceContainer:Get(
	name: string
)


	return self.Services[name]

end







------------------------------------------------
-- Servis durdurma
------------------------------------------------


function ServiceContainer:StopAll()


	for name, service in pairs(
		self.Services
	) do




		if self.Started[name]
		and service.Stop then



			pcall(

				service.Stop

			)



		end




	end




	table.clear(
		self.Started
	)


end







------------------------------------------------
-- Tam temizlik
------------------------------------------------


function ServiceContainer:Destroy()


	self:StopAll()



	for _,service in pairs(
		self.Services
	) do



		if service.Cleanup then


			pcall(
				service.Cleanup
			)


		end


	end





	table.clear(
		self.Services
	)


end







return ServiceContainer

--!strict
-- InstanceManager.lua
--
-- Roblox Instance lifecycle yöneticisi.
--
-- Özellikler:
--  - Model yükleme
--  - Folder yükleme
--  - Hierarchy koruma
--  - Runtime ownership
--  - Otomatik cleanup


local InstanceManager = {}
InstanceManager.__index = InstanceManager





function InstanceManager.new(runtime)


	local self = setmetatable({}, InstanceManager)


	self.Runtime = runtime


	self.Loaded = {}


	return self

end







------------------------------------------------
-- Instance kaydetme
------------------------------------------------


function InstanceManager:Register(
	instance: Instance
)


	if not instance then
		return
	end




	self.Runtime.Resources:RegisterInstance(
		instance
	)




	table.insert(
		self.Loaded,
		instance
	)




	return instance

end







------------------------------------------------
-- Instance yükleme
------------------------------------------------


function InstanceManager:Load(
	object: Instance,
	parent: Instance?
)


	assert(
		object,
		"Instance gerekli"
	)




	local clone =
		object:Clone()





	-- Parent korunur

	clone.Parent =
		parent
		or object.Parent






	self:Register(
		clone
	)





	self.Runtime.Logger:Info(

		"Instance loaded: "
		.. clone.Name

	)





	return clone

end







------------------------------------------------
-- Folder yükleme
------------------------------------------------


function InstanceManager:LoadFolder(
	folder: Folder,
	parent: Instance?
)


	local container =
		Instance.new("Folder")



	container.Name =
		folder.Name





	container.Parent =
		parent
		or folder.Parent






	self:Register(
		container
	)







	for _,child in ipairs(
		folder:GetChildren()
	) do



		local clone =
			child:Clone()



		clone.Parent =
			container




		self:Register(
			clone
		)



	end





	return container

end







------------------------------------------------
-- Recursive kayıt
------------------------------------------------
--
-- Büyük hierarchy için
-- GetDescendants tek sefer kullanılır.


function InstanceManager:RegisterTree(
	root: Instance
)


	self:Register(
		root
	)




	local descendants =
		root:GetDescendants()






	for _,object in ipairs(
		descendants
	) do



		self:Register(
			object
		)



	end





end







------------------------------------------------
-- Temizlik
------------------------------------------------


function InstanceManager:Destroy()


	table.clear(
		self.Loaded
	)


end





return InstanceManager

--!strict
-- Bootstrap.lua
--
-- Runtime başlangıç yöneticisi.
--
-- Görevleri:
--  - Runtime oluşturma
--  - Config uygulama
--  - Module yükleme
--  - Service yükleme
--  - Başlatma sırası


local Bootstrap = {}





local RuntimeManager =
	require(script.Parent.RuntimeManager)





export type BootstrapConfig = {


	Name: string?,


	Debug: boolean?,


	AutoCleanup: boolean?,


	LoggingLevel: string?,



	Modules: Instance?,


	Services: table?



}







function Bootstrap.Start(
	config: BootstrapConfig?
)


	config =
		config
		or {}





	------------------------------------------------
	-- Runtime oluştur
	------------------------------------------------


	local runtime =
		RuntimeManager.new(

			config.Name
			or "Runtime",

			{


				Debug =
					config.Debug
					or false,



				AutoCleanup =
					config.AutoCleanup
					or true,



				LoggingLevel =
					config.LoggingLevel
					or "INFO"


			}

		)








	------------------------------------------------
	-- Runtime init
	------------------------------------------------


	runtime:Init()








	------------------------------------------------
	-- Services
	------------------------------------------------


	if config.Services then



		for name,service in pairs(
			config.Services
		) do



			runtime:RegisterService(
				name,
				service
			)



		end


	end









	------------------------------------------------
	-- Modules
	------------------------------------------------


	if config.Modules then



		runtime.Modules:LoadFolder(

			config.Modules

		)


	end







	------------------------------------------------
	-- Çalıştır
	------------------------------------------------


	runtime:Start()






	return runtime


end







return Bootstrap

--!strict
-- ConnectionManager.lua
--
-- Roblox event lifecycle yöneticisi.
--
-- Yönetir:
--  - RBXScriptConnection
--  - otomatik disconnect
--  - runtime ownership
--  - bağlantı takibi


local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager





function ConnectionManager.new(runtime)


	local self =
		setmetatable({}, ConnectionManager)



	self.Runtime =
		runtime



	self.Connections =
		{}



	return self

end







------------------------------------------------
-- Yeni bağlantı oluştur
------------------------------------------------


function ConnectionManager:Connect(
	event,
	callback
)


	assert(
		event,
		"Event gerekli"
	)



	assert(
		type(callback)
		==
		"function",
		"Callback function olmalı"
	)







	local connection =
		event:Connect(
			callback
		)






	-- ResourceManager sahipliği

	self.Runtime.Resources:RegisterConnection(
		connection
	)






	table.insert(
		self.Connections,
		connection
	)







	return connection

end







------------------------------------------------
-- Tek bağlantı sil
------------------------------------------------


function ConnectionManager:Disconnect(
	connection
)


	if not connection then
		return
	end





	if connection.Connected then

		connection:Disconnect()

	end





	for i,value in ipairs(
		self.Connections
	) do



		if value == connection then


			table.remove(
				self.Connections,
				i
			)


			break

		end



	end





end







------------------------------------------------
-- Hepsini kapat
------------------------------------------------


function ConnectionManager:DisconnectAll()


	for _,connection in ipairs(
		self.Connections
	) do



		pcall(function()


			if connection.Connected then

				connection:Disconnect()

			end



		end)



	end






	table.clear(
		self.Connections
	)


end







------------------------------------------------
-- Cleanup
------------------------------------------------


function ConnectionManager:Destroy()


	self:DisconnectAll()



end







function ConnectionManager:GetCount()

	return #self.Connections

end







return ConnectionManager

--!strict
-- ConfigManager.lua
--
-- Runtime ayar sistemi.
--
-- Sağlar:
--  - Default config
--  - Override
--  - Güvenli erişim
--  - Runtime ayar değişimi


local ConfigManager = {}
ConfigManager.__index = ConfigManager





local DefaultConfig = {


	------------------------------------------------
	-- Runtime
	------------------------------------------------

	Debug = false,


	AutoCleanup = true,


	LoggingLevel = "INFO",




	------------------------------------------------
	-- Performance
	------------------------------------------------

	Performance = {


		MaxTasksPerTick = 50,


		EnableProfiling = false,


		CacheModules = true


	},





	------------------------------------------------
	-- Safety
	------------------------------------------------

	Safety = {


		CatchErrors = true,


		StopOnCriticalError = false


	}


}







function ConfigManager.new(
	custom
)


	local self =
		setmetatable({}, ConfigManager)






	self.Data =
		table.clone(
			DefaultConfig
		)






	if custom then

		self:_Merge(
			self.Data,
			custom
		)

	end





	return self

end







------------------------------------------------
-- Recursive merge
------------------------------------------------


function ConfigManager:_Merge(
	target,
	source
)


	for key,value in pairs(
		source
	) do



		if type(value)
			==
			"table"
		and type(target[key])
			==
			"table"
		then



			self:_Merge(
				target[key],
				value
			)



		else


			target[key] =
				value


		end


	end



end







------------------------------------------------
-- Ayar alma
------------------------------------------------


function ConfigManager:Get(
	key
)


	return self.Data[key]

end







------------------------------------------------
-- Nested erişim
------------------------------------------------


function ConfigManager:GetPath(
	...
)


	local current =
		self.Data



	for _,key in ipairs(
		{
			...
		}
	) do



		if current[key]
			==
			nil
		then

			return nil

		end



		current =
			current[key]

	end





	return current

end







------------------------------------------------
-- Ayar değiştirme
------------------------------------------------


function ConfigManager:Set(
	key,
	value
)


	self.Data[key] =
		value


end







function ConfigManager:GetAll()

	return self.Data

end







return ConfigManager

--!strict
-- Profiler.lua
--
-- Runtime performans takip sistemi.
--
-- Ölçer:
--  - Module süreleri
--  - Task süreleri
--  - Service süreleri
--
-- Amaç:
-- Büyük projelerde darboğaz bulmak.


local Profiler = {}
Profiler.__index = Profiler





function Profiler.new(runtime)


	local self =
		setmetatable({}, Profiler)



	self.Runtime =
		runtime



	self.Enabled =
		runtime.Config:GetPath(
			"Performance",
			"EnableProfiling"
		)



	self.Records = {}



	return self

end







------------------------------------------------
-- Timer başlat
------------------------------------------------


function Profiler:Start(
	name
)


	if not self.Enabled then
		return nil
	end



	return os.clock()

end







------------------------------------------------
-- Timer bitir
------------------------------------------------


function Profiler:Stop(
	name,
	startTime
)


	if not self.Enabled then
		return
	end



	if not startTime then
		return
	end



	local duration =
		os.clock()
		-
		startTime






	local record =
		self.Records[name]






	if not record then


		record = {


			Count = 0,


			Total = 0,


			Average = 0,


			Max = 0


		}



		self.Records[name] =
			record



	end







	record.Count += 1


	record.Total += duration



	record.Average =
		record.Total
		/
		record.Count






	if duration > record.Max then

		record.Max =
			duration

	end




end







------------------------------------------------
-- Wrapper
------------------------------------------------


function Profiler:Measure(
	name,
	callback
)


	local start =
		self:Start(name)




	local result =
		callback()





	self:Stop(
		name,
		start
	)



	return result

end







------------------------------------------------
-- Rapor
------------------------------------------------


function Profiler:GetReport()


	return self.Records


end







------------------------------------------------
-- En yavaşlar
------------------------------------------------


function Profiler:GetSlowest(
	count
)


	count =
		count
		or 5



	local list = {}




	for name,data in pairs(
		self.Records
	) do



		table.insert(
			list,
			{
				Name = name,
				Time = data.Average
			}
		)


	end






	table.sort(
		list,
		function(a,b)

			return a.Time > b.Time

		end
	)






	local result = {}



	for i = 1,
		math.min(
			count,
			#list
		)
	do


		table.insert(
			result,
			list[i]
		)


	end




	return result

end







function Profiler:Destroy()


	table.clear(
		self.Records
	)


end







return Profiler