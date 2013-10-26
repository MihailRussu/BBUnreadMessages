<%@ page import="blackboard.base.BbList" %>
<%@ page import="blackboard.data.course.Course" %>
<%@ page import="blackboard.data.message.Message" %>
<%@ page import="blackboard.data.message.MessageBox" %>
<%@ page import="blackboard.data.message.MessageFolder" %>
<%@ page import="blackboard.data.user.User" %>
<%@ page import="blackboard.persist.course.CourseDbLoader" %>
<%@ page import="java.text.Format" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="blackboard.platform.plugin.PlugInUtil" %>
<%@ taglib prefix="bbData" uri="/bbData" %>

<bbData:context id="ctx">
    <%
        try {
            //getting current user
            User user = ctx.getUser();
            //initializing course loader
            CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
            //getting list of all courses current user is enrolled in
            BbList<Course> courses = courseLoader.loadByUserId(user.getId());
            String email_img_url = PlugInUtil.getUri("mcmo", "unreadmsgs", "email.png") ;    //WARNING! HARDCODED bb-manifest.xml data

            int unread_courses = 0;
            for (int i = 0; i < courses.size(); i++) {
                Course c = courses.get(i);
                if (!c.getIsAvailable()) {
                    continue; //skipp unavailable courses
                }

                if ((ctx.getCourse() != null) && (!ctx.getCourse().getCourseId().equals(c.getCourseId()))){
                   continue;  //if a module inside a course then skipping to the next course unless we are inside current course
                }

                MessageBox msgbox = MessageBox.initMessageBox(user, c);
                MessageFolder inbox = msgbox.getInboxFolder();
                List<Message> unredmsgs = inbox.getUnreadMessageList();
                if (unredmsgs.size() > 0) {
                    unread_courses++;
                    out.println("<table style='with:100%; max-width:100%; table-layout:fixed;'>");
                    String mailbox_url = "/webapps/blackboard/messaging/course/messageList.jsp?course_id=" + c.getId().toExternalString() + "&nav=messages&folder=inbox";
                    out.println("<caption><a href='" + mailbox_url + "'><img style='vertical-align:middle;' src='"+email_img_url+"' />&nbsp;<b>"+ inbox.getUnreadMessageCount() +" new message(s) in " + c.getTitle() + "</b></a></caption>");
                    out.println("<tr>");
                    out.println("<th style='width:33.33%'><b>Sender</b></th>");
                    out.println("<th style='width:33.33%'><b>Subject</b></th>");
                    out.println("<th style='width:33.33%'><b>Date</b></th>");
                    out.println("</tr>");
                    for (int n = 0; n < unredmsgs.size(); n++) {

                        if (n >= 3) {
                            out.println("<tr><td colspan=3><center><a href='" + mailbox_url + "'>Go to course email messages to see more</a></center></td></tr>");
                            break;
                        }

                        Message msg = unredmsgs.get(n);
                        User sender = msg.getFrom();

                        Format formatter = new SimpleDateFormat("MMM dd, yyyy 'at' KK:mm a");
                        String msgsent = formatter.format(msg.getDateCreated());
                        String msg_url = "/webapps/blackboard/messaging/course/messageDetail.jsp?course_id=" + c.getId().toExternalString() + "&nav=messages&folder=inbox&message_id=" + msg.getMessageId();
                        out.println("<tr>");
                        out.println("<td><a href='" + msg_url + "'>" + sender.getGivenName() + " " + sender.getFamilyName() + "</a></td>");
                        out.println("<td><a href='" + msg_url + "'>" + msg.getSubject() + "</a></td>");
                        out.println("<td><a href='" + msg_url + "'>" + msgsent + "</a></td>");
                        out.println("</tr>");
                    }
                    out.println("</table><br/>");
                }
            }
            if (unread_courses == 0) {
                out.println("<div class='noItems'>You currently don't have any unread course messages</div>");
            }
        } catch (Throwable e) {
            out.println("<H1>" + e.getMessage() + "</H1>");
        }
    %>
</bbData:context>