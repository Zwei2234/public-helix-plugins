local PLUGIN = PLUGIN

PLUGIN.name = "Chatbox Quote Highlighting"
PLUGIN.author = "Zwei"
PLUGIN.description = "Highlights text between double quotes with a separate, user-configurable color. Overrides ixChatboxHistory derma."
-- This needs to be overridden if you use a custom chatbox plugin. Used for calling CreateChat()
PLUGIN.baseChatbox = ix.plugin.Get("chatbox")


ix.lang.AddTable("english", {
	optQuoteHighlight = "Enable Quote Highlighting",
	optdQuoteHighlight = "If enabled, any text inbetween two double quotes will be highlighted with the Color option.",
	optQuoteHighlightColor = "Quote Highlighting Color",
	optdQuoteHighlightColor = "Color of quote highlighting.",
})

if CLIENT then
    ix.option.Add("quoteHighlight", ix.type.bool, true, {
		category = "chat",
		OnChanged = function()
            if PLUGIN.baseChatbox then
			    PLUGIN.baseChatbox:CreateChat()
            end
		end
	})

	ix.option.Add("quoteHighlightColor", ix.type.color, Color(255, 255, 255), {
		category = "chat",
	})
end