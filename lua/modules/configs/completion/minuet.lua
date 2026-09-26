return function()
	local prediction = require("modules.utils.ai").get_prediction_config()
	if not prediction then
		vim.notify(
			"Minuet prediction requires `pred_adapter` to reference an OpenAI-compatible or FIM-compatible entry in `ai_adapters`.",
			vim.log.levels.ERROR,
			{ title = "minuet-ai.nvim" }
		)
		return
	end

	local provider = prediction.provider
	require("modules.utils").load_plugin("minuet", {
		provider = provider,
		n_completions = provider == "openai_fim_compatible" and 1 or nil,
		provider_options = {
			[provider] = {
				api_key = prediction.api_key,
				end_point = prediction.end_point,
				model = prediction.model,
				name = prediction.name,
				optional = prediction.optional,
			},
		},
	})
end
