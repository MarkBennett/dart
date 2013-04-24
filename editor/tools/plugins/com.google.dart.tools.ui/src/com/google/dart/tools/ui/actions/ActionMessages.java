/*
 * Copyright (c) 2012, the Dart project authors.
 * 
 * Licensed under the Eclipse Public License v1.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.google.dart.tools.ui.actions;

import org.eclipse.osgi.util.NLS;

import java.util.ResourceBundle;

public final class ActionMessages extends NLS {

  private static final String BUNDLE_NAME = "com.google.dart.tools.ui.actions.ActionMessages";//$NON-NLS-1$
  private static final ResourceBundle bundle = ResourceBundle.getBundle(BUNDLE_NAME);
  static {
    NLS.initializeMessages(BUNDLE_NAME, ActionMessages.class);
  }

  public static String OpenResourceAction_label;
  public static String OpenResourceAction_error_title;
  public static String OpenResourceAction_error_message;

  public static String EditAction_label;
  public static String EditAction_description;

  public static String AboutDartAction_about_text;

  public static String AboutDartAction_about_tooltip;

  public static String AbstractOpenWizardAction_noproject_title;
  public static String AbstractOpenWizardAction_noproject_message;
  public static String AbstractOpenWizardAction_createerror_title;
  public static String AbstractOpenWizardAction_createerror_message;

  public static String ActionUtil_warning_derived_dontShowAgain;

  public static String ActionUtil_warning_derived_message;
  public static String ActionUtil_warning_derived_title;
  public static String AddDelegateMethodsAction_not_in_source_file;
  public static String AddDelegateMethodsAction_template_link_message;

  public static String AddDelegateMethodsAction_template_link_tooltip;
  public static String AddGetterSetterAction_allow_setters_for_finals_description;
  public static String AddGetterSetterAction_error_not_in_source_file;
  public static String AddGetterSetterAction_template_link_description;
  public static String AddGetterSetterAction_template_link_tooltip;
  public static String AddUnimplementedConstructorsAction_template_link_message;
  public static String AddUnimplementedConstructorsAction_template_link_tooltip;
  public static String GenerateConstructorUsingFieldsSelectionDialog_template_link_message;

  public static String GenerateConstructorUsingFieldsSelectionDialog_template_link_tooltip;
  public static String CopyQualifiedNameAction_ActionName;
  public static String CopyQualifiedNameAction_ErrorDescription;
  public static String CopyQualifiedNameAction_ErrorTitle;
  public static String CopyQualifiedNameAction_InfoDialogTitel;
  public static String CopyQualifiedNameAction_NoElementToQualify;
  public static String CopyQualifiedNameAction_ToolTipText;

  public static String DeleteResourceAction_titleProject1;
  public static String DeleteResourceAction_titleProjectN;
  public static String DeleteResourceAction_confirmProject1;
  public static String DeleteResourceAction_confirmProjectN;
  public static String DeleteResourceAction_deleteContents1;
  public static String DeleteResourceAction_deleteContentsN;
  public static String DeleteResourceAction_deleteContentsDetails;

  public static String FindNLSProblemsAction_Description;
  public static String FindNLSProblemsAction_ErrorDialogTitle;
  public static String FindNLSProblemsAction_Name;
  public static String FindNLSProblemsAction_NoPropertieFilesFoundErrorDescription;
  public static String FindNLSProblemsAction_ToolTip;
  public static String FormatAllAction_problem_accessing;
  public static String FormatAllAction_read_only_skipped;
  public static String GenerateNewConstructorUsingFieldsAction_error_not_a_source_file;
  public static String OpenAction_error_problem_opening_editor;
  public static String OpenAction_multistatus_message;
  public static String OpenViewActionGroup_showInAction_label;
  public static String OpenWithMenu_label;
  public static String RefactorMenu_label;

  public static String SourceMenu_label;
  public static String BuildPath_label;
  public static String BuildAction_label;
  public static String SelectionConverter_codeResolve_failed;
  public static String OpenAction_label;
  public static String OpenAction_tooltip;
  public static String OpenAction_description;
  public static String OpenAction_declaration_label;
  public static String OpenAction_select_element;
  public static String OpenAction_error_title;
  public static String OpenAction_error_message;
  public static String OpenAction_error_messageBadSelection;
  public static String OpenSuperImplementationAction_label;
  public static String OpenSuperImplementationAction_tooltip;
  public static String OpenSuperImplementationAction_description;
  public static String OpenSuperImplementationAction_error_title;
  public static String OpenSuperImplementationAction_error_message;
  public static String OpenSuperImplementationAction_not_applicable;
  public static String OpenSuperImplementationAction_no_super_implementation;
  public static String OpenTypeHierarchyAction_label;
  public static String OpenTypeHierarchyAction_tooltip;
  public static String OpenTypeHierarchyAction_description;
  public static String OpenTypeHierarchyAction_dialog_title;
  public static String OpenTypeHierarchyAction_messages_title;
  public static String OpenTypeHierarchyAction_messages_no_java_element;
  public static String OpenTypeHierarchyAction_messages_no_java_resources;
  public static String OpenTypeHierarchyAction_messages_no_types;
  public static String OpenTypeHierarchyAction_messages_no_valid_java_element;
  public static String OpenTypeHierarchyAction_messages_unknown_import_decl;
  public static String OverrideMethodsAction_label;
  public static String OverrideMethodsAction_description;
  public static String OverrideMethodsAction_tooltip;
  public static String OverrideMethodsAction_error_actionfailed;
  public static String OverrideMethodsAction_error_title;
  public static String OverrideMethodsAction_error_nothing_found;
  public static String OverrideMethodsAction_not_applicable;
  public static String OverrideMethodsAction_interface_not_applicable;
  public static String OverrideMethodsAction_annotation_not_applicable;
  public static String CleanUpAction_label;

  public static String CleanUpAction_labelWizard;
  public static String CleanUpAction_tooltip;
  public static String CleanUpAction_description;
  public static String CleanUpAction_MultiStateErrorTitle;
  public static String CleanUpAction_UnexpectedErrorMessage;
  public static String CleanUpAction_CUNotOnBuildpathMessage;
  public static String CleanUpAction_EmptySelection_description;
  public static String CleanUpAction_actionName;
  public static String AddGetterSetterAction_no_primary_type_title;

  public static String AddGetterSetterAction_no_primary_type_message;
  public static String AddGetterSetterAction_label;
  public static String AddGetterSetterAction_description;
  public static String AddGetterSetterAction_tooltip;
  public static String AddGetterSetterAction_error_duplicate_methods;
  public static String AddGetterSetterAction_error_title;
  public static String AddGetterSetterAction_error_actionfailed;
  public static String AddGetterSetterAction_not_applicable;
  public static String AddGetterSetterAction_interface_not_applicable;
  public static String AddGetterSetterAction_annotation_not_applicable;
  public static String AddGetterSetterAction_QueryDialog_title;
  public static String AddGetterSetterAction_SkipExistingDialog_message;
  public static String AddGetterSetterAction_SkipExistingDialog_skip_label;
  public static String AddGetterSetterAction_SkipExistingDialog_replace_label;
  public static String AddGetterSetterAction_SkipExistingDialog_skipAll_label;
  public static String AddGetterSetterAction_dialog_label;
  public static String AddGetterSetterAction_methods_selected;
  public static String AddGettSetterAction_typeContainsNoFields_message;
  public static String GetterSetterTreeSelectionDialog_select_getters;

  public static String GetterSetterTreeSelectionDialog_select_setters;
  public static String GetterSetterTreeSelectionDialog_alpha_pair_sort;
  public static String GetterSetterTreeSelectionDialog_alpha_method_sort;
  public static String GetterSetterTreeSelectionDialog_sort_label;
  public static String SourceActionDialog_enterAt_label;
  public static String SourceActionDialog_modifier_group;
  public static String SourceActionDialog_modifier_public;
  public static String SourceActionDialog_modifier_protected;
  public static String SourceActionDialog_modifier_default;
  public static String SourceActionDialog_modifier_private;
  public static String SourceActionDialog_modifier_synchronized;
  public static String SourceActionDialog_modifier_final;
  public static String SourceActionDialog_first_method;
  public static String SourceActionDialog_last_method;
  public static String SourceActionDialog_cursor;
  public static String SourceActionDialog_after;
  public static String SourceActionDialog_createMethodComment;
  public static String SourceActionDialog_no_entries;
  public static String SourceActionDialog_createConstructorComment;
  public static String AddUnimplementedConstructorsAction_label;
  public static String AddUnimplementedConstructorsAction_description;
  public static String AddUnimplementedConstructorsAction_tooltip;
  public static String AddUnimplementedConstructorsAction_error_title;
  public static String AddUnimplementedConstructorsAction_not_applicable;
  public static String AddUnimplementedConstructorsAction_interface_not_applicable;
  public static String AddUnimplementedConstructorsAction_enum_not_applicable;
  public static String AddUnimplementedConstructorsAction_annotation_not_applicable;
  public static String AddUnimplementedConstructorsAction_methods_selected;
  public static String AddUnimplementedConstructorsAction_error_nothing_found;
  public static String AddUnimplementedConstructorsAction_dialog_title;
  public static String AddUnimplementedConstructorsAction_dialog_label;
  public static String AddUnimplementedConstructorsDialog_omit_super;
  public static String GenerateConstructorUsingFieldsAction_label;
  public static String GenerateConstructorUsingFieldsAction_description;
  public static String GenerateConstructorUsingFieldsAction_tooltip;
  public static String GenerateConstructorUsingFieldsAction_error_title;
  public static String GenerateConstructorUsingFieldsAction_not_applicable;
  public static String GenerateConstructorUsingFieldsAction_fields_selected;
  public static String GenerateConstructorUsingFieldsAction_error_duplicate_constructor;
  public static String GenerateConstructorUsingFieldsAction_error_nothing_found;
  public static String GenerateConstructorUsingFieldsAction_dialog_title;
  public static String GenerateConstructorUsingFieldsAction_dialog_label;
  public static String GenerateConstructorUsingFieldsAction_interface_not_applicable;
  public static String GenerateConstructorUsingFieldsAction_enum_not_applicable;
  public static String GenerateConstructorUsingFieldsAction_annotation_not_applicable;
  public static String GenerateConstructorUsingFieldsAction_typeContainsNoFields_message;
  public static String GenerateConstructorUsingFieldsAction_error_actionfailed;
  public static String GenerateConstructorUsingFieldsSelectionDialog_up_button;
  public static String GenerateConstructorUsingFieldsSelectionDialog_down_button;
  public static String GenerateConstructorUsingFieldsSelectionDialog_sort_constructor_choices_label;
  public static String GenerateConstructorUsingFieldsSelectionDialog_omit_super;
  public static String GenerateConstructorUsingFieldsAction_error_anonymous_class;
  public static String AddJavaDocStubAction_label;

  public static String AddJavaDocStubAction_description;
  public static String AddJavaDocStubAction_tooltip;
  public static String AddJavaDocStubsAction_error_dialogTitle;
  public static String AddJavaDocStubsAction_error_actionFailed;
  public static String AddJavaDocStubsAction_not_applicable;
  public static String ExternalizeStringsAction_label;
  public static String ExternalizeStringsAction_dialog_title;
  public static String ExternalizeStringsAction_dialog_message;
  public static String FindStringsToExternalizeAction_label;
  public static String FindStringsToExternalizeAction_dialog_title;
  public static String FindStringsToExternalizeAction_error_message;
  public static String FindStringsToExternalizeAction_error_cannotBeParsed;
  public static String FindStringsToExternalizeAction_foundStrings;
  public static String FindStringsToExternalizeAction_noStrings;
  public static String FindStringsToExternalizeAction_non_externalized;
  public static String FindStringsToExternalizeAction_button_label;
  public static String FindStringsToExternalizeAction_find_strings;

  public static String OpenExternalDartdocAction_label;
  public static String OpenExternalDartdocAction_description;
  public static String OpenExternalDartdocAction_tooltip;

  public static String GenerateJavascriptAction_Compiling;
  public static String GenerateJavascriptAction_title;
  public static String GenerateJavascriptAction_description;
  public static String GenerateJavascriptAction_DoneSuccess;
  public static String GenerateJavascriptAction_tooltip;
  public static String GenerateJavascriptAction_jobTitle;
  public static String GenerateJavascriptAction_noneSelected;
  public static String GenerateJavascriptAction_unableToLaunch;
  public static String GenerateJavascriptAction_errorLaunching;
  public static String GenerateJavascriptAction_errorCompiling;
  public static String GenerateJavascriptAction_Fail;
  public static String GenerateJavascriptAction_FailException;
  public static String GenerateJavascriptAction_FailMessage;
  public static String GenerateJavascriptAction_GenerateMessage;

  public static String GenerateDartdocAction_Compiling;
  public static String GenerateDartdocAction_title;
  public static String GenerateDartdocAction_description;
  public static String GenerateDartdocAction_tooltip;
  public static String GenerateDartdocAction_jobTitle;
  public static String GenerateDartdocAction_unableToLaunch;
  public static String GenerateDartdocAction_noneSelected;
  public static String GenerateDartdocAction_FailException;

  public static String SelfEncapsulateFieldAction_label;
  public static String SelfEncapsulateFieldAction_dialog_title;
  public static String SelfEncapsulateFieldAction_dialog_unavailable;
  public static String SelfEncapsulateFieldAction_dialog_cannot_perform;
  public static String OrganizeImportsAction_label;
  public static String OrganizeImportsAction_tooltip;
  public static String OrganizeImportsAction_description;
  public static String OrganizeImportsAction_multi_error_parse;
  public static String OrganizeImportsAction_multi_error_unresolvable;
  public static String OrganizeImportsAction_selectiondialog_title;
  public static String OrganizeImportsAction_selectiondialog_message;
  public static String OrganizeImportsAction_error_title;
  public static String OrganizeImportsAction_error_message;
  public static String OrganizeImportsAction_single_error_parse;
  public static String OrganizeImportsAction_summary_added;
  public static String OrganizeImportsAction_summary_removed;
  public static String OrganizeImportsAction_summary_added_singular;
  public static String OrganizeImportsAction_summary_added_plural;
  public static String OrganizeImportsAction_summary_removed_singular;
  public static String OrganizeImportsAction_summary_removed_plural;
  public static String OrganizeImportsAction_EmptySelection_description;
  public static String OrganizeImportsAction_EmptySelection_title;
  public static String FormatAllAction_label;

  public static String FormatAllAction_tooltip;
  public static String FormatAllAction_description;
  public static String FormatAllAction_status_description;
  public static String FormatAllAction_multi_status_title;
  public static String FormatAllAction_error_title;
  public static String FormatAllAction_error_message;
  public static String FormatAllAction_operation_description;
  public static String FormatAllAction_noundo_title;
  public static String FormatAllAction_noundo_message;
  public static String FormatAllAction_EmptySelection_description;
  public static String FormatAllAction_EmptySelection_title;
  public static String SortMembersAction_label;

  public static String SortMembersAction_tooltip;
  public static String SortMembersAction_description;
  public static String SortMembersAction_not_applicable;
  public static String SortMembersAction_containsmarkers;
  public static String SortMembersAction_dialog_title;
  public static String MemberFilterActionGroup_hide_fields_label;
  public static String MemberFilterActionGroup_hide_fields_tooltip;
  public static String MemberFilterActionGroup_hide_fields_description;
  public static String MemberFilterActionGroup_hide_static_label;
  public static String MemberFilterActionGroup_hide_static_tooltip;
  public static String MemberFilterActionGroup_hide_static_description;
  public static String MemberFilterActionGroup_hide_nonpublic_label;
  public static String MemberFilterActionGroup_hide_nonpublic_tooltip;
  public static String MemberFilterActionGroup_hide_nonpublic_description;
  public static String MemberFilterActionGroup_hide_localtypes_label;
  public static String MemberFilterActionGroup_hide_localtypes_tooltip;
  public static String MemberFilterActionGroup_hide_localtypes_description;
  public static String NewWizardsActionGroup_new;
  public static String OpenProjectAction_dialog_title;
  public static String OpenProjectAction_dialog_message;
  public static String OpenProjectAction_error_message;
  public static String OpenJavaPerspectiveAction_dialog_title;
  public static String OpenJavaPerspectiveAction_error_open_failed;
  public static String OpenJavaBrowsingPerspectiveAction_dialog_title;
  public static String OpenJavaBrowsingPerspectiveAction_error_open_failed;
  public static String OpenTypeInHierarchyAction_label;
  public static String OpenTypeInHierarchyAction_description;
  public static String OpenTypeInHierarchyAction_tooltip;
  public static String OpenTypeInHierarchyAction_dialogMessage;
  public static String OpenTypeInHierarchyAction_dialogTitle;
  public static String RefreshAction_label;
  public static String RefreshAction_toolTip;
  public static String RefreshAction_progressMessage;
  public static String RefreshAction_error_title;
  public static String RefreshAction_error_message;
  public static String RefreshAction_locationDeleted_title;
  public static String RefreshAction_locationDeleted_message;
  public static String ModifyParameterAction_problem_title;
  public static String ModifyParameterAction_problem_message;
  public static String ActionUtil_notOnBuildPath_title;
  public static String ActionUtil_notOnBuildPath_message;
  public static String ActionUtil_notOnBuildPath_resource_message;
  public static String ActionUtil_not_possible;
  public static String ActionUtil_no_linked;
  public static String SelectAllAction_label;
  public static String SelectAllAction_tooltip;
  public static String AddToClasspathAction_label;
  public static String AddToClasspathAction_toolTip;
  public static String AddToClasspathAction_progressMessage;
  public static String AddToClasspathAction_error_title;
  public static String AddToClasspathAction_error_message;
  public static String RemoveFromClasspathAction_Remove;
  public static String RemoveFromClasspathAction_tooltip;
  public static String RemoveFromClasspathAction_Removing;
  public static String RemoveFromClasspathAction_exception_dialog_title;
  public static String RemoveFromClasspathAction_Problems_occurred;
  public static String RunPubAction_savePubspecMessage;
  public static String RunPubAction_fileNotFound;
  public static String RunPubAction_fail;
  public static String RunPubAction_publish_missing_requirements;
  public static String RunPubAction_publish_dialog_title;
  public static String RunPubAction_publish_upload_message;
  public static String RunPubAction_publish_upload_cancel;
  public static String AddDelegateMethodsAction_error_title;
  public static String AddDelegateMethodsAction_error_actionfailed;
  public static String AddDelegateMethodsAction_label;
  public static String AddDelegateMethodsAction_description;
  public static String AddDelegateMethodsAction_tooltip;
  public static String AddDelegateMethodsAction_not_applicable;
  public static String AddDelegateMethodsAction_annotation_not_applicable;
  public static String AddDelegateMethodsAction_interface_not_applicable;
  public static String AddDelegateMethodsAction_duplicate_methods;
  public static String AddDelegateMethodsAction_title;
  public static String AddDelegateMethodsAction_message;
  public static String AddDelegateMethodsAction_selectioninfo_more;
  public static String SurroundWithTemplateMenuAction_ConfigureTemplatesActionName;

  public static String SurroundWithTemplateMenuAction_NoneApplicable;
  public static String SurroundWithTemplateMenuAction_SurroundWithTemplateSubMenuName;
  public static String SurroundWithTemplateMenuAction_SurroundWithTryCatchActionName;
  public static String ToggleLinkingAction_label;

  public static String ToggleLinkingAction_tooltip;
  public static String ToggleLinkingAction_description;
  public static String ConfigureContainerAction_error_title;
  public static String ConfigureContainerAction_error_creationfailed_message;
  public static String ConfigureContainerAction_error_applyingfailed_message;
  public static String FindExceptionOccurrences_text;
  public static String FindExceptionOccurrences_toolTip;
  public static String FindImplementOccurrencesAction_text;
  public static String FindImplementOccurrencesAction_toolTip;
  public static String CategoryFilterActionGroup_JavaCategoryFilter_title;

  public static String CategoryFilterActionGroup_SelectAllCategories;
  public static String CategoryFilterActionGroup_DeselectAllCategories;
  public static String CategoryFilterActionGroup_SelectCategoriesDescription;
  public static String CategoryFilterActionGroup_ShowCategoriesActionDescription;
  public static String CategoryFilterActionGroup_ShowCategoriesToolTip;
  public static String CategoryFilterActionGroup_ShowCategoriesLabel;
  public static String CategoryFilterActionGroup_ShowUncategorizedMembers;

  public static String OpenNewFileWizardAction_text;
  public static String OpenNewFileWizardAction_description;
  public static String OpenNewFileWizardAction_tooltip;

  public static String OpenNewFolderWizardAction_text;
  public static String OpenNewFolderWizardAction_description;
  public static String OpenNewFolderWizardAction_tooltip;

  // public static String OpenNewAnnotationWizardAction_text;
  // public static String OpenNewAnnotationWizardAction_description;
  // public static String OpenNewAnnotationWizardAction_tooltip;
  public static String OpenNewClassWizardAction_text;

  public static String OpenNewClassWizardAction_description;
  public static String OpenNewClassWizardAction_tooltip;
  // public static String OpenNewEnumWizardAction_text;
  // public static String OpenNewEnumWizardAction_description;
  // public static String OpenNewEnumWizardAction_tooltip;
  public static String OpenNewInterfaceWizardAction_text;
  public static String OpenNewInterfaceWizardAction_description;
  public static String OpenNewInterfaceWizardAction_tooltip;
  public static String OpenNewDartProjectWizardAction_text;
  public static String OpenNewDartProjectWizardAction_description;
  public static String OpenNewDartProjectWizardAction_tooltip;
  public static String OpenNewPackageWizardAction_text;
  public static String OpenNewPackageWizardAction_description;
  public static String OpenNewPackageWizardAction_tooltip;
  public static String OpenNewSourceFolderWizardAction_text;
  public static String OpenNewSourceFolderWizardAction_text2;
  public static String OpenNewSourceFolderWizardAction_description;
  public static String OpenNewSourceFolderWizardAction_tooltip;

  public static String CollapseAllAction_label;
  public static String CollapseAllAction_tooltip;
  public static String CollapseAllAction_description;

  public static String OpenOnlineDocsAction_text;
  public static String OpenOnlineDocsAction_description;
  public static String OpenOnlineDocsAction_tooltip;
  public static String OpenOnlineDocsAction_href;

  public static String OpenApiDocsAction_text;
  public static String OpenApiDocsAction_description;
  public static String OpenApiDocsAction_tooltip;
  public static String OpenApiDocsAction_href;

  public static String OpenTutorialAction_text;
  public static String OpenTutorialAction_description;
  public static String OpenTutorialAction_tooltip;
  public static String OpenTutorialAction_href;

  public static String OpenAsTextAction_description;
  public static String OpenAsTextAction_title;
  public static String OpenAsTextAction_toolTip;
  public static String CopyFilePathAction_text;
  public static String CopyFilePathAction_description;
  public static String CopyFilePathAction_tooltip;
  public static String CopyFilePathAction_dialogTitle;
  public static String CopyFilePathAction_dialogMessage;

  public static String OpenExistingFolderWizardAction_tooltip;
  public static String OpenExistingFolderWizardAction_description;
  public static String OpenExistingFolderWizardAction_text;

  public static String RunPubAction_commandDesc;
  public static String RunPubAction_commandText;

  public static ResourceBundle getBundle() {
    return bundle;
  }

  //	public static String GenerateBuildPathActionGroup_update_jar_text;
//	public static String GenerateBuildPathActionGroup_update_jar_description;
//	public static String GenerateBuildPathActionGroup_update_jar_tooltip;
  private ActionMessages() {
    // Do not instantiate
  }
}
