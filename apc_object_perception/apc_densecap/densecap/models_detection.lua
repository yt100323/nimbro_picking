local M = {}

function M.setup(opt)
  local model
  if opt.checkpoint_start_from == '' then
    print('initializing a Detection model from scratch...')
    model = DetectionModel(opt)
  else
    print('initializing a Detection model from ' .. opt.checkpoint_start_from)
    model = torch.load(opt.checkpoint_start_from).model
    --[[
    model.opt.objectness_weight = opt.objectness_weight
    model.nets.localization_layer.opt.obj_weight = opt.objectness_weight
    model.opt.box_reg_weight = opt.box_reg_weight
    model.crits.box_reg_crit.w = opt.end_box_reg_weight
    model.opt.classification_weight = opt.classification_weight
    local rpn = model.nets.localization_layer.nets.rpn
    rpn:findModules('nn.RegularizeLayer')[1].w = opt.box_reg_decay
    model.opt.sampler_high_thresh = opt.iou_high_thresh
    model.opt.sampler_low_thresh = opt.iou_low_thresh
    model.opt.train_remove_outbounds_boxes = opt.train_remove_outbounds_boxes
    model.opt.captioning_weight = opt.captioning_weight --]]

    if cudnn then
      cudnn.convert(model.net, cudnn)
      cudnn.convert(model.nets.localization_layer.nets.rpn, cudnn)
    end
  end

  -- Find all Dropout layers and set their probabilities
  local dropout_modules = model.nets.recog_base:findModules('nn.Dropout')
  for i, dropout_module in ipairs(dropout_modules) do
    dropout_module.p = opt.drop_prob
  end
  model:float()

  return model
end

return M

